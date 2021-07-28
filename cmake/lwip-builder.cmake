include(cmake/package.cmake)

# --- lwip2 src/Filelists.cmake expects these to be provided

set(LWIP_DEFINITIONS
    ${GLUE_COMMON_DEFINITIONS}
    -DLWIP_BUILD
)
set(LWIP_INCLUDE_DIRS
    "${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/include"
    "${ESP8266_ARDUINO_CORE_DIR}/tools/sdk/libc/xtensa-lx106-elf/include"
    "${ESP8266_ARDUINO_CORE_DIR}/cores/esp8266"
    "${LWIP_DIR}/src/include"
    "${CMAKE_SOURCE_DIR}/glue"
    "${CMAKE_SOURCE_DIR}/glue-esp"
    "${CMAKE_SOURCE_DIR}/glue-lwip"
    "${CMAKE_SOURCE_DIR}/glue-lwip/arduino"
    "${CMAKE_BINARY_DIR}/common"
)
set(LWIP_COMPILER_FLAGS
    -g
)

#include(${LWIP_DIR}/src/Filelists.cmake)

function(glue_variant)
    cmake_parse_arguments(
        GLUE_VARIANT
        ""
        "NAME"
        "DEFINITIONS"
        ${ARGN}
    )

    message(STATUS "new target " ${GLUE_VARIANT_NAME} ", with definitions " "${GLUE_VARIANT_DEFINITIONS}")

    # lwip library itself, based off of the lwipcore flags
    # (adjust based on Filelists, if that is ever changed)
    get_target_property(LWIPCORE_SOURCES lwipcore SOURCES)
    add_library(${GLUE_VARIANT_NAME}-core STATIC
        ${LWIPCORE_SOURCES}
        ${LWIP_DIR}/src/apps/sntp/sntp.c
        ${LWIP_DIR}/src/apps/mdns/mdns.c
    )

    target_compile_options(${GLUE_VARIANT_NAME}-core PRIVATE ${LWIP_COMPILER_FLAGS})
    target_compile_definitions(${GLUE_VARIANT_NAME}-core PRIVATE
        ${LWIP_DEFINITIONS}
        ${GLUE_VARIANT_DEFINITIONS}
        ${GLUE_COMMON_DEFINITIONS}
    )
    target_include_directories(${GLUE_VARIANT_NAME}-core PRIVATE ${LWIP_INCLUDE_DIRS})

    # Part that is supposed to talk to the lwip2
    add_library(${GLUE_VARIANT_NAME}-glue STATIC
        ${CMAKE_SOURCE_DIR}/glue-lwip/lwip-git.c
        ${CMAKE_SOURCE_DIR}/glue-lwip/esp-dhcpserver.c
        ${CMAKE_SOURCE_DIR}/glue-lwip/esp-ping.c
        ${CMAKE_SOURCE_DIR}/glue-lwip/espconn.c
        ${CMAKE_SOURCE_DIR}/glue-lwip/espconn_buf.c
        ${CMAKE_SOURCE_DIR}/glue-lwip/espconn_tcp.c
        ${CMAKE_SOURCE_DIR}/glue-lwip/espconn_udp.c
    )
    target_include_directories(${GLUE_VARIANT_NAME}-glue BEFORE
        PRIVATE
        ${CMAKE_SOURCE_DIR}/glue-lwip/
        ${CMAKE_SOURCE_DIR}/glue/
        ${LWIP_INCLUDE_DIRS}
    )
    target_compile_definitions(${GLUE_VARIANT_NAME}-glue
        PRIVATE
        ${GLUE_COMMON_DEFINITIONS}
        ${GLUE_VARIANT_DEFINITIONS}
    )

    # Debug utils for the -glue package
    add_library(${GLUE_VARIANT_NAME}-glue-debug STATIC
        ${CMAKE_SOURCE_DIR}/glue/doprint.c
        ${CMAKE_SOURCE_DIR}/glue/uprint.c
    )
    target_include_directories(${GLUE_VARIANT_NAME}-glue-debug BEFORE
        PRIVATE
        ${CMAKE_SOURCE_DIR}/glue-lwip/
        ${CMAKE_SOURCE_DIR}/glue/
        ${LWIP_INCLUDE_DIRS}
    )
    target_compile_definitions(${GLUE_VARIANT_NAME}-glue-debug
        PRIVATE
        ${GLUE_COMMON_DEFINITIONS}
        ${GLUE_VARIANT_DEFINITIONS}
    )

    # Parts of lwip that are called from SDK side. Re-maps them to lwip2
    add_library(${GLUE_VARIANT_NAME}-glue-esp STATIC
        ${CMAKE_SOURCE_DIR}/glue-esp/lwip-esp.c
    )

    target_include_directories(${GLUE_VARIANT_NAME}-glue-esp BEFORE
        PRIVATE
        ${CMAKE_SOURCE_DIR}/glue-esp/lwip-1.4-arduino/include/
        ${CMAKE_SOURCE_DIR}/glue-lwip/
        ${CMAKE_SOURCE_DIR}/glue/
        ${LWIP_INCLUDE_DIRS}
    )

    target_compile_definitions(${GLUE_VARIANT_NAME}-glue-esp
        PRIVATE
        -DLWIP14GLUE
        ${GLUE_COMMON_DEFINITIONS}
        ${GLUE_VARIANT_DEFINITIONS}
    )

    # --- dummy link target so that we build all of the libraries
    # --- and also combine them into a single .a

    target_link_libraries(${GLUE_VARIANT_NAME}-glue
        PUBLIC
        ${GLUE_VARIANT_NAME}-core
        ${GLUE_VARIANT_NAME}-glue-debug
        ${GLUE_VARIANT_NAME}-glue-esp
    )

    add_library(${GLUE_VARIANT_NAME} STATIC
        $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-glue>
        $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-glue-esp>
        $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-glue-debug>
        $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-core>
    )

    install(TARGETS ${GLUE_VARIANT_NAME} ARCHIVE)

endfunction()
