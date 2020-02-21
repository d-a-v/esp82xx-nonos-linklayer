cmake_minimum_required(VERSION 3.9)
project(lwip-glue-builder VERSION 20200212 DESCRIPTION "lwip-glue-builder" LANGUAGES NONE)

include(ExternalProject)

# --- set this to update the tracked repo
# --- TODO: patch command needs to be aware of the change, somehow?

set(LWIP_TAG "STABLE-2_1_2_RELEASE")

# --- adjust relative paths to absolute

set(LWIP_DIR "${CMAKE_SOURCE_DIR}/lwip2-src")

set(ESP8266_ARDUINO_CORE_DIR ${CMAKE_SOURCE_DIR}/../../../../ CACHE FILEPATH "Arduino Core default path")
set(ESP8266_TOOLCHAIN_PATH ${ESP8266_ARDUINO_CORE_DIR}/tools/xtensa-lx106-elf/bin CACHE FILEPATH "Toolchain default path")

get_filename_component(ESP8266_ARDUINO_CORE_DIR ${ESP8266_ARDUINO_CORE_DIR} REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")
get_filename_component(LWIP_DIR ${LWIP_DIR} REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")

file(TO_NATIVE_PATH ${LWIP_DIR} LWIP_DIR_NATIVE)
file(TO_NATIVE_PATH ${ESP8266_ARDUINO_CORE_DIR} ESP8266_ARDUINO_CORE_DIR_NATIVE)

if (NOT EXISTS ${ESP8266_TOOLCHAIN_PATH})
    message(SEND_ERROR ${ESP8266_TOOLCHAIN_PATH})
    message(FATAL_ERROR "Toolchain directory does not exist")
endif()

message(STATUS "toolchain: " ${ESP8266_TOOLCHAIN_PATH})
message(STATUS "core dir: " "${ESP8266_ARDUINO_CORE_DIR}")
message(STATUS "lwip dir: " "${LWIP_DIR}")
message(STATUS "lwip tag: " "${LWIP_TAG}")

# --- fetch lwip when needed
# --- we don't keep it as submodule to allow build tools that recursively check-out main repo avoid always downloading lwip2-src
# --- checkout and everything else is handled by patch & clean targets

file(GLOB LWIP_PATCHES ${CMAKE_SOURCE_DIR}/patches/*.patch)

ExternalProject_Add(lwip2-src
    GIT_REPOSITORY https://git.savannah.nongnu.org/git/lwip.git
    GIT_TAG ${LWIP_TAG}
    GIT_SHALLOW ON
    GIT_PROGRESS ON
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/lwip2-src
    INSTALL_COMMAND ""
    BUILD_COMMAND ""
    CONFIGURE_COMMAND ""
    PATCH_COMMAND git apply -3 --recount --whitespace=fix ${LWIP_PATCHES}
)

ExternalProject_Add(glue-package
    BUILD_ALWAYS TRUE
    DOWNLOAD_COMMAND ""
    SOURCE_DIR ${CMAKE_SOURCE_DIR}/cmake/package
    CMAKE_ARGS
        -DLWIP_DIR=${LWIP_DIR}
        -DGLUE_DIR=${CMAKE_SOURCE_DIR}
        -DESP8266_ARDUINO_CORE_DIR=${ESP8266_ARDUINO_CORE_DIR}
)

# --- handle
# include "lwip-git-hash.h"
# include "lwip-err-t.h"
# --- both come from SDK lwip header

# TODO: Put files to ${CMAKE_BINARY_DIR}? No need to pollute source dir
#       Can be passed to ExternalProject via -DGLUE_INCLUDE_DIR=${CMAKE_BINARY_DIR}
# TODO: A single ${CMAKE_BINARY_DIR}/glue-generated.h?

# --- our variants setup.
# - directory cmake/<GLUE_VARIANT_NAME> must exist
# - it should follow this template, where set(...) are -D... values
#
# cmake_minimum_required(VERSION 3.9)
# project(some-arbitrary-name LANGUAGES C)
#
# set(TCP_MSS ...)
# set(LWIP_IPV6 ...)
# set(LWIP_FEATURES ...)
#
# include(lwip-builder.cmake)
#

# TODO:
# - allow to pass some other args?
# - add_directory? lwip filelists could not be included, since we hit name collision when creating lwipcore and glue targets multiple times
#   source lists would repeat current Makefile, probably skipping polarssl bits and directly including sntp & mdns sources

# - ExternalProject will install lib<variant>.a to the ESP8266_ARDUINO_CORE_DIR

file(GLOB GLUE_VARIANT_DIRS LIST_DIRECTORIES true ${CMAKE_SOURCE_DIR}/cmake/variants/*)

foreach(GLUE_VARIANT_DIR ${GLUE_VARIANT_DIRS})

    get_filename_component(GLUE_VARIANT_NAME ${GLUE_VARIANT_DIR} NAME)
    message(STATUS "Preparing ${GLUE_VARIANT_NAME}")

    ExternalProject_Add(${GLUE_VARIANT_NAME}
        BUILD_ALWAYS TRUE
        DOWNLOAD_COMMAND ""
        SOURCE_DIR ${GLUE_VARIANT_DIR}
        INSTALL_DIR ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake
            -DCMAKE_PROGRAM_PATH=${ESP8266_TOOLCHAIN_PATH}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/cmake/toolchain.cmake
            -DGLUE_VARIANT_NAME=${GLUE_VARIANT_NAME}
            -DGLUE_DIR=${CMAKE_SOURCE_DIR}
            -DESP8266_ARDUINO_CORE_DIR=${ESP8266_ARDUINO_CORE_DIR}
            -DLWIP_DIR=${LWIP_DIR}
    )
    add_dependencies(${GLUE_VARIANT_NAME} lwip2-src glue-package)

endforeach()
