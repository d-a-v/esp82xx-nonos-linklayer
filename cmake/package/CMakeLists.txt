cmake_minimum_required(VERSION 3.9)
project(lwip-glue-package VERSION 1 DESCRIPTION "lwip-glue-package" LANGUAGES NONE)

# - get info about the build system

execute_process(
    COMMAND git describe --tag
    WORKING_DIRECTORY "${GLUE_DIR}"
    OUTPUT_VARIABLE GLUE_REPO_DESC_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND git describe --tag
    WORKING_DIRECTORY "${LWIP_DIR}"
    OUTPUT_VARIABLE LWIP_REPO_DESC_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# - generated headers, required to build lwip-glue
# - TODO: modifies source tree in-place, perhaps use runtime dir to generate and add installed headers path to glue variant as target_include_directory()?

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

message(STATUS "glue desc: " ${GLUE_REPO_DESC_STR})
message(STATUS "typedefs: " ${GLUE_LWIP_TYPEDEF_STRINGS})
message(STATUS "err_t: " ${GLUE_LWIP_ERR_T_DEFINITION})

# - TODO: instead of using source dir, use runtime directory or use install()'ed include path as glue variant include path

configure_file(
    "${GLUE_DIR}/glue-lwip/lwip-err-t.h.in"
    "${GLUE_DIR}/glue-lwip/lwip-err-t.h"
    @ONLY
)

configure_file(
    "${GLUE_DIR}/glue-lwip/lwip-git-hash.h.in"
    "${GLUE_DIR}/glue-lwip/lwip-git-hash.h"
    @ONLY
)

list(APPEND SOURCES "${GLUE_DIR}/glue-lwip/lwip-err-t.h")
list(APPEND SOURCES "${GLUE_DIR}/glue-lwip/lwip-git-hash.h")

# - We need to distribute current version of lwip2 & glue headers with the Core

install(DIRECTORY ${LWIP_DIR}/src/include
    DESTINATION ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2
    FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY ${GLUE_DIR}/glue-lwip/arch
    DESTINATION ${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/lwip2/include
    FILES_MATCHING PATTERN "*.h"
)

install(FILES
    ${GLUE_DIR}/glue-lwip/arduino/lwipopts.h
    ${GLUE_DIR}/glue-lwip/lwip-git-hash.h
    ${GLUE_DIR}/glue-lwip/lwip-err-t.h
    ${GLUE_DIR}/glue-lwip/lwip/apps-esp/dhcpserver.h
    ${GLUE_DIR}/glue/glue.h
    ${GLUE_DIR}/glue/gluedebug.h
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

