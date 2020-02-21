cmake_minimum_required(VERSION 3.9)
project(lwip-glue-builder VERSION 1 DESCRIPTION "lwip-glue-builder" LANGUAGES NONE)

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

include(ExternalProject)

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

# --- info about the build system
# --- LWIP is most likely a custom tag name, glue should be tag + N-commits

execute_process(
    COMMAND git describe --tag
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE GLUE_REPO_DESC_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND git describe --tag
    WORKING_DIRECTORY "${LWIP_DIR}"
    OUTPUT_VARIABLE LWIP_REPO_DESC_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "glue desc: " ${GLUE_REPO_DESC_STR})

# --- handle
# include "lwip-git-hash.h"
# include "lwip-err-t.h"
# --- both come from SDK lwip header

# TODO: Put files to ${CMAKE_BINARY_DIR}? No need to pollute source dir
#       Can be passed to ExternalProject via -DGLUE_INCLUDE_DIR=${CMAKE_BINARY_DIR}
# TODO: A single ${CMAKE_BINARY_DIR}/glue-generated.h?

set(LWIP_ARCH_CC_H tools/sdk/lwip/include/arch/cc.h)
get_filename_component(LWIP_ARCH_CC_H ${LWIP_ARCH_CC_H} REALPATH BASE_DIR "${ESP8266_ARDUINO_CORE_DIR}")
file(TO_NATIVE_PATH ${LWIP_ARCH_CC_H} LWIP_ARCH_CC_H)

if (CMAKE_HOST_WIN32)
    set(CMD_GREP_TYPEDEF findstr typedef ${LWIP_ARCH_CC_H})
    set(CMD_GREP_ERR_T findstr LWIP_ERR_T ${LWIP_ARCH_CC_H})
else()
    set(CMD_GREP_TYPEDEF grep -E "^typedef" ${LWIP_ARCH_CC_H})
    set(CMD_GREP_ERR_T grep "LWIP_ERR_T" ${LWIP_ARCH_CC_H})
endif()

execute_process(
    COMMAND ${CMD_GREP_TYPEDEF}
    WORKING_DIRECTORY "${ESP8266_ARDUINO_CORE_DIR}"
    OUTPUT_VARIABLE GLUE_LWIP_TYPEDEF_STRINGS
)
execute_process(
    COMMAND ${CMD_GREP_ERR_T}
    WORKING_DIRECTORY "${ESP8266_ARDUINO_CORE_DIR}"
    OUTPUT_VARIABLE GLUE_LWIP_ERR_T_DEFINITION
)

if (NOT GLUE_LWIP_TYPEDEF_STRINGS)
    message(FATAL_ERROR "No typedef strings found")
endif()

if (NOT GLUE_LWIP_ERR_T_DEFINITION)
    message(FATAL_ERROR "No LWIP_ERR_T string found")
endif()

configure_file(
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h.in"
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h"
    @ONLY
)

configure_file(
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-git-hash.h.in"
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-git-hash.h"
    @ONLY
)

list(APPEND SOURCES "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h")
list(APPEND SOURCES "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-git-hash.h")

message(STATUS "typedefs: " ${GLUE_LWIP_TYPEDEF_STRINGS})
message(STATUS "err_t: " ${GLUE_LWIP_ERR_T_DEFINITION})

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
        BUILD_ALWAYS ON
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
    add_dependencies(${GLUE_VARIANT_NAME} lwip2-src)

endforeach()

# - We need to distribute current version of lwip2 & glue headers with the Core

install(DIRECTORY ${LWIP_DIR}/src/include
    DESTINATION ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2/include
    FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY ${CMAKE_SOURCE_DIR}/glue-lwip/arch
    DESTINATION ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2/include/arch
    FILES_MATCHING PATTERN "*.h"
)

install(FILES
    ${CMAKE_SOURCE_DIR}/glue-lwip/arduino/lwipopts.h
    ${CMAKE_SOURCE_DIR}/glue-lwip/lwip-git-hash.h
    ${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h
    ${CMAKE_SOURCE_DIR}/glue-lwip/lwip/apps-esp/dhcpserver.h
    ${CMAKE_SOURCE_DIR}/glue/glue.h
    ${CMAKE_SOURCE_DIR}/glue/gluedebug.h
    DESTINATION ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2/include
)

# - Adding notice about the origin of files in ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2/include

file(GENERATE
    OUTPUT ${CMAKE_BINARY_DIR}/README.md
    CONTENT "Warning! This directory will be re/over/written from lwip2 builder upon lwip2 rebuild. Current version was built with lwip:${LWIP_REPO_DESC_STR} glue:${GLUE_REPO_DESC_STR}"
)

install(FILES
    ${CMAKE_BINARY_DIR}/README.md
    DESTINATION ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2/include
)

