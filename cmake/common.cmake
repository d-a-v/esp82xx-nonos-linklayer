# prerequisite auto-generated files, common between variants

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

set(LWIP_ARCH_CC_H ${CMAKE_SOURCE_DIR}/glue-esp/lwip-1.4-arduino/include/arch/cc.h)
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

configure_file(
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-err-t.h.in"
    "${CMAKE_BINARY_DIR}/common/lwip-err-t.h"
    @ONLY
)

configure_file(
    "${CMAKE_SOURCE_DIR}/glue-lwip/lwip-git-hash.h.in"
    "${CMAKE_BINARY_DIR}/common/lwip-git-hash.h"
    @ONLY
)

# TODO: Instead of glue-lwip/lwip-err-t.h having:
#       #define LWIP_NO_STDINT_H 1
#       Just add it here?

set(GLUE_COMMON_DEFINITIONS
    -DARDUINO
    -D__ets__
    -DICACHE_FLASH
    -DLWIP_OPEN_SRC
    -DUSE_OPTIMIZE_PRINTF
)
