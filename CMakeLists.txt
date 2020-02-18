# Draft of cmake integration. For now, only supports Arduino as target
# To run:
# $ mkdir build
# $ cd build/
# $ cmake ../ -DESP8266_ARDUINO_CORE_DIR=<PATH_TO_THE_ARDUINO_CORE_ROOT> -DESP8266_TOOLCHAIN_PATH=<PATH_TO_TOOLCHAIN_BIN_DIRECTORY>
# $ cmake --build .
# or
# $ make

cmake_minimum_required(VERSION 3.9)
project(lwip-glue-builder VERSION 1 DESCRIPTION "lwip-glue-builder" LANGUAGES NONE)

# --- set this to update the tracked repo
# --- TODO: patch command needs to be aware of the change, somehow?

set(LWIP_TAG "STABLE-2_1_2_RELEASE")

# --- adjust relative paths to absolute

set(LWIP_DIR "${CMAKE_SOURCE_DIR}/lwip2-src")

get_filename_component(ESP8266_ARDUINO_CORE_DIR ${ESP8266_ARDUINO_CORE_DIR} REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")
get_filename_component(LWIP_DIR ${LWIP_DIR} REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")

file(TO_NATIVE_PATH ${LWIP_DIR} LWIP_DIR_NATIVE)
file(TO_NATIVE_PATH ${ESP8266_ARDUINO_CORE_DIR} ESP8266_ARDUINO_CORE_DIR_NATIVE)

set(ESP8266_TOOLCHAIN_PATH ${ESP8266_ARDUINO_CORE_DIR}/tools/xtensa-lx106-elf/bin CACHE INTERNAL "Toolchain default path")
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
    PATCH_COMMAND git apply -3 --whitespace=fix ${LWIP_PATCHES}
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

if (WIN32)
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
configure_file(
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h.in"
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h"
    @ONLY
)

# --- TODO: perhaps, we can even use a target_compile_definitions(lwipcore, ...) in externalproject

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
# include(../builder.cmake)
#

# LIB_INSTALL_DIR=... is a customizable prefix
# when build is done, resulting library .a will be copied to ${LIB_INSTALL_DIR}/lib/lib${GLUE_VARIANT_NAME}.a

# TODO:
# - allow to pass some other args?
# - add_directory? lwip filelists could not be included, since we hit name collision when creating lwipcore and glue targets multiple times
#   source lists would repeat current Makefile, probably skipping polarssl bits and directly including sntp & mdns sources

#set(LWIP_VARIANTS lwip2-536 lwip2-536-feat lwip2-1460 lwip2-1460-feat lwip6-536-feat lwip6-1460-feat)

foreach(GLUE_VARIANT_NAME lwip2-536 lwip2-536-feat lwip2-1460 lwip2-1460-feat lwip6-536-feat lwip6-1460-feat)

    message(STATUS "Preparing ${GLUE_VARIANT_NAME}")
    ExternalProject_Add(${GLUE_VARIANT_NAME}
        BUILD_ALWAYS ON
        DOWNLOAD_COMMAND ""
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/cmake/${GLUE_VARIANT_NAME}
        INSTALL_DIR ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DGLUE_VARIANT_NAME=${GLUE_VARIANT_NAME}
            -DGLUE_DIR=${CMAKE_SOURCE_DIR}
            -DCMAKE_PROGRAM_PATH=${ESP8266_TOOLCHAIN_PATH}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/cmake/toolchain.cmake
            -DESP8266_ARDUINO_CORE_DIR=${ESP8266_ARDUINO_CORE_DIR}
            -DLWIP_DIR=${LWIP_DIR}
    )
    add_dependencies(${GLUE_VARIANT_NAME} lwip2-src)

endforeach()
