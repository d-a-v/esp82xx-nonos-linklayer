cmake_minimum_required(VERSION 3.9)

# --- we are expected to be included from variant CMakeLists.txt
set(CMAKE_C_STANDARD 99)
set(GLUE_C_FLAGS TCP_MSS=${TCP_MSS} LWIP_IPV6=${LWIP_IPV6} LWIP_FEATURES=${LWIP_FEATURES})

# --- lwip2 src/Filelists.cmake expects these to be provided
# --- following creates `add_library(lwipcore ...)` and `add_library(lwipallapps)`
# --- we only need mdns and sntp on top of the core configuration

# TODO: glue-lwip/lwip-err-t.h defines this!
#       -DLWIP_NO_STDINT_H=1
#       Should probably be here instead
set (GLUE_DEFINITIONS
    -DARDUINO
    -D__ets__
    -DICACHE_FLASH
    -DLWIP_OPEN_SRC
    -DUSE_OPTIMIZE_PRINTF
)

set (LWIP_DEFINITIONS
    ${GLUE_DEFINITIONS}
    -DLWIP_BUILD
)
set (LWIP_INCLUDE_DIRS
    "${ARDUINO_DIR}/tools/sdk/include"
    "${ARDUINO_DIR}/tools/sdk/libc/xtensa-lx106-elf/include"
    "${ARDUINO_DIR}/cores/esp8266"
    "${LWIP_DIR}/src/include"
    "${GLUE_DIR}/glue"
    "${GLUE_DIR}/glue-esp"
    "${GLUE_DIR}/glue-lwip"
    "${GLUE_DIR}/glue-lwip/arduino"
)
set(LWIP_COMPILER_FLAGS
    -g
)

include(${LWIP_DIR}/src/Filelists.cmake)

target_sources(lwipcore
    PRIVATE
    ${lwipsntp_SRCS}
    ${lwipmdns_SRCS}
)

# --- all the source code from the glue-lwip/...
# --- TODO: arduino target does not need millis() stub
add_library(${GLUE_VARIANT_NAME}-glue STATIC
    ${GLUE_DIR}/glue-lwip/lwip-git.c
    ${GLUE_DIR}/glue-lwip/esp-dhcpserver.c
    ${GLUE_DIR}/glue-lwip/esp-ping.c
    ${GLUE_DIR}/glue-lwip/espconn.c
    ${GLUE_DIR}/glue-lwip/espconn_buf.c
    ${GLUE_DIR}/glue-lwip/espconn_tcp.c
    ${GLUE_DIR}/glue-lwip/espconn_udp.c
)

add_library(${GLUE_VARIANT_NAME}-debug STATIC
    ${GLUE_DIR}/glue/doprint.c
    ${GLUE_DIR}/glue/uprint.c
)

add_library(${GLUE_VARIANT_NAME}-esp STATIC
    ${GLUE_DIR}/glue-esp/lwip-esp.c
)

target_include_directories(${GLUE_VARIANT_NAME}-glue BEFORE
    PRIVATE
    ${GLUE_DIR}/glue-lwip/
    ${GLUE_DIR}/glue/
    ${LWIP_INCLUDE_DIRS}
)
target_include_directories(${GLUE_VARIANT_NAME}-debug BEFORE
    PRIVATE
    ${GLUE_DIR}/glue-lwip/
    ${GLUE_DIR}/glue/
    ${LWIP_INCLUDE_DIRS}
)
target_include_directories(${GLUE_VARIANT_NAME}-esp BEFORE
    PRIVATE
    ${ARDUINO_DIR}/tools/sdk/lwip/include
    ${GLUE_DIR}/glue-lwip/
    ${GLUE_DIR}/glue/
    ${LWIP_INCLUDE_DIRS}
)

if($(GLUE_TARGET) EQUAL OPENSDK)
    target_sources(${GLUE_VARIANT_NAME}-glue
        PRIVATE
        ${GLUE_DIR}/glue-lwip/esp-time.c
        ${GLUE_DIR}/glue-lwip/esp-millis.c
    )
endif()

target_compile_definitions(${GLUE_VARIANT_NAME}-glue PRIVATE ${GLUE_DEFINITIONS})
target_compile_definitions(${GLUE_VARIANT_NAME}-glue PRIVATE ${GLUE_C_FLAGS})

target_compile_definitions(${GLUE_VARIANT_NAME}-debug PRIVATE ${GLUE_DEFINITIONS})
target_compile_definitions(${GLUE_VARIANT_NAME}-debug PRIVATE ${GLUE_C_FLAGS})

target_compile_definitions(${GLUE_VARIANT_NAME}-esp PRIVATE ${GLUE_DEFINITIONS})
target_compile_definitions(${GLUE_VARIANT_NAME}-esp PRIVATE ${GLUE_C_FLAGS})

target_compile_definitions(lwipcore PRIVATE ${GLUE_C_FLAGS})

target_link_libraries(${GLUE_VARIANT_NAME}-glue PUBLIC lwipcore ${GLUE_VARIANT_NAME}-debug ${GLUE_VARIANT_NAME}-esp)

add_library(${GLUE_VARIANT_NAME} STATIC
    $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-glue>
    $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-esp>
    $<TARGET_OBJECTS:${GLUE_VARIANT_NAME}-debug>
    $<TARGET_OBJECTS:lwipcore>
)

install(TARGETS ${GLUE_VARIANT_NAME} ARCHIVE DESTINATION ".")
