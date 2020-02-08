# Draft of cmake integration. For now, only supports Arduino as target
# To run:
# $ mkdir build
# $ cd build/
# $ cmake ../ -DARDUINO_DIR=<PATH_TO_THE_ARDUINO_CORE_ROOT> -DCMAKE_PROGRAM_PATH=<PATH_TO_TOOLCHAIN_BIN_DIRECTORY>
# $ cmake --build .
# or
# $ make

cmake_minimum_required(VERSION 3.9)
project(lwip-glue-builder VERSION 1 DESCRIPTION "lwip-glue-builder" LANGUAGES NONE)

# --- TODO: "describe" arduino/esp8266 as toolchain?
set(LWIP_DIR "${CMAKE_SOURCE_DIR}/lwip2-src")
set(LWIP_TAG "STABLE-2_1_2_RELEASE")
#set(LWIP_VARIANTS liblwip2-1460 liblwip2-1460-feat liblwip2-536 liblwip2-536-feat liblwip6-1460-feat liblwip6-536-feat)

# --- adjust relative paths to absolute
get_filename_component(ARDUINO_DIR ${ARDUINO_DIR} REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")
get_filename_component(LWIP_DIR ${LWIP_DIR} REALPATH BASE_DIR "${CMAKE_SOURCE_DIR}")

message(STATUS "arduino dir: " "${ARDUINO_DIR}")
message(STATUS "lwip dir: " "${LWIP_DIR}")

# --- patch / undo patch from our special directory

set(LWIP_PATCH_COMMAND ${CMAKE_SOURCE_DIR}/scripts/patch-lwip2-src ${CMAKE_SOURCE_DIR}/patches ${LWIP_DIR})
set(LWIP_CLEAN_COMMAND ${CMAKE_SOURCE_DIR}/scripts/clean-lwip2-src ${LWIP_DIR})

# --- fetch lwip when needed
# --- we don't keep it as submodule to allow build tools that recursively check-out main repo avoid always downloading lwip2-src
# --- checkout and everything else is handled by patch & clean targets

if(NOT EXISTS "${LWIP_DIR}")
    message(STATUS "Fetching ${LWIP_TAG}")
    execute_process(
        COMMAND git clone --depth=1 -b ${LWIP_TAG} https://git.savannah.nongnu.org/git/lwip.git ${LWIP_DIR}
    )
endif()

add_custom_command(
    OUTPUT "${LWIP_DIR}/.patched"
    COMMAND ${LWIP_PATCH_COMMAND}
    COMMENT "Patching ${LWIP_DIR}"
)

# --- following creates two makefile targets, allowing us to manually patch or clean lwip2-src

add_custom_target(patch-lwip-sources
    ALL
    COMMAND ${LWIP_PATCH_COMMAND}
    DEPENDS "${LWIP_DIR}/.patched"
)
add_custom_target(clean-lwip-sources
    COMMAND ${LWIP_CLEAN_COMMAND}
    COMMENT "Cleaning ${LWIP_DIR}"
)

# --- info about the build system
# --- LWIP is most likely a custom tag name, glue should be tag + N-commits

execute_process(
    COMMAND sh -c "git describe --tag"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE GLUE_REPO_DESC_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND sh -c "git describe --tag"
    WORKING_DIRECTORY "${LWIP_DIR}"
    OUTPUT_VARIABLE LWIP_REPO_DESC_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "glue desc: " ${GLUE_REPO_DESC_STR})
message(STATUS "lwip desc: " ${LWIP_REPO_DESC_STR})

# --- handle
# include "lwip-git-hash.h"
# include "lwip-err-t.h"
# --- both come from SDK lwip header

# TODO: Put files to ${CMAKE_BINARY_DIR}? No need to pollute source dir
#       Can be passed to ExternalProject via -DGLUE_INCLUDE_DIR=${CMAKE_BINARY_DIR}
# TODO: A single ${CMAKE_BINARY_DIR}/glue-generated.h?

execute_process(
    COMMAND grep -E "^typedef" tools/sdk/lwip/include/arch/cc.h
    WORKING_DIRECTORY "${ARDUINO_DIR}"
    OUTPUT_VARIABLE GLUE_LWIP_TYPEDEF_STRINGS
)
execute_process(
    COMMAND grep -E "LWIP_ERR_T" tools/sdk/lwip/include/arch/cc.h
    WORKING_DIRECTORY "${ARDUINO_DIR}"
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
# - cmake/<GLUE_VARIANT_NAME> must exist
# - it should follow this template:
#
# cmake_minimum_required(VERSION 3.9)
# project(lwip2-1460 LANGUAGES C)
# 
# set(TCP_MSS 1460)
# set(LWIP_IPV6 0)
# set(LWIP_FEATURES 0)
# 
# include(../builder.cmake)

# TODO:
# - INSTALL_DIR should be provided by user? small install() hack in cmake/builder.cmake puts it directly there, without lib/ directory
# - allow to pass some other args?

include(ExternalProject)

foreach(GLUE_VARIANT_NAME liblwip2-1460 liblwip2-536)

    message(STATUS "Preparing ${GLUE_VARIANT_NAME}")
    ExternalProject_Add(${GLUE_VARIANT_NAME}
        DOWNLOAD_COMMAND ""
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/cmake/${GLUE_VARIANT_NAME}
        INSTALL_DIR ${CMAKE_SOURCE_DIR}/output
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DGLUE_VARIANT_NAME=${GLUE_VARIANT_NAME}
            -DGLUE_DIR=${CMAKE_SOURCE_DIR}
            -DCMAKE_PROGRAM_PATH=${CMAKE_PROGRAM_PATH}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_SOURCE_DIR}/cmake/toolchain.cmake
            -DARDUINO_DIR=${ARDUINO_DIR}
            -DLWIP_DIR=${LWIP_DIR}
    )
    add_dependencies(${GLUE_VARIANT_NAME} patch-lwip-sources)

endforeach()
