cmake_minimum_required(VERSION 3.9)

# --- we are expected to be included from variant CMakeLists.txt
set(CMAKE_C_STANDARD 99)
set(GLUE_C_FLAGS TCP_MSS=${TCP_MSS} LWIP_IPV6=${LWIP_IPV6} LWIP_FEATURES=${LWIP_FEATURES})

# TODO: Instead of glue-lwip/lwip-err-t.h having:
#       #define LWIP_NO_STDINT_H 1
#       Just add it here
set (GLUE_DEFINITIONS
    -DARDUINO
    -D__ets__
    -DICACHE_FLASH
    -DLWIP_OPEN_SRC
    -DUSE_OPTIMIZE_PRINTF
)

# --- lwip2 src/Filelists.cmake expects these to be provided
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

# --- following creates `add_library(lwipcore ...)` and `add_library(lwipallapps)`
# --- we only need mdns and sntp on top of the core configuration
include(${LWIP_DIR}/src/Filelists.cmake)

target_sources(lwipcore
    PRIVATE
    ${lwipsntp_SRCS}
    ${lwipmdns_SRCS}
)

# Main part that is supposed to talk to the lwip2
add_library(glue STATIC
    ${GLUE_DIR}/glue-lwip/lwip-git.c
    ${GLUE_DIR}/glue-lwip/esp-dhcpserver.c
    ${GLUE_DIR}/glue-lwip/esp-ping.c
    ${GLUE_DIR}/glue-lwip/espconn.c
    ${GLUE_DIR}/glue-lwip/espconn_buf.c
    ${GLUE_DIR}/glue-lwip/espconn_tcp.c
    ${GLUE_DIR}/glue-lwip/espconn_udp.c
)

target_include_directories(glue BEFORE
    PRIVATE
    ${GLUE_DIR}/glue-lwip/
    ${GLUE_DIR}/glue/
    ${LWIP_INCLUDE_DIRS}
)

target_compile_definitions(glue PRIVATE ${GLUE_DEFINITIONS})
target_compile_definitions(glue PRIVATE ${GLUE_C_FLAGS})

# Debug utils
add_library(glue-debug STATIC
    ${GLUE_DIR}/glue/doprint.c
    ${GLUE_DIR}/glue/uprint.c
)

target_include_directories(glue-debug BEFORE
    PRIVATE
    ${GLUE_DIR}/glue-lwip/
    ${GLUE_DIR}/glue/
    ${LWIP_INCLUDE_DIRS}
)
target_compile_definitions(glue-debug PRIVATE ${GLUE_DEFINITIONS})
target_compile_definitions(glue-debug PRIVATE ${GLUE_C_FLAGS})

# Parts of lwip that are called from SDK side. Re-maps them to lwip2
add_library(glue-esp STATIC
    ${GLUE_DIR}/glue-esp/lwip-esp.c
)

target_include_directories(glue-esp BEFORE
    PRIVATE
    ${ARDUINO_DIR}/tools/sdk/lwip/include
    ${GLUE_DIR}/glue-lwip/
    ${GLUE_DIR}/glue/
    ${LWIP_INCLUDE_DIRS}
)

target_compile_definitions(glue-esp PRIVATE ${GLUE_DEFINITIONS})
target_compile_definitions(glue-esp PRIVATE ${GLUE_C_FLAGS})

# TODO: ???
target_compile_definitions(lwipcore PRIVATE ${GLUE_C_FLAGS})

# --- finally, add a dummy link target so that we build all of the libraries
target_link_libraries(glue PUBLIC lwipcore glue-debug glue-esp)

# --- then, combine .o from them in a single archive
add_library(${GLUE_VARIANT_NAME} STATIC
    $<TARGET_OBJECTS:glue>
    $<TARGET_OBJECTS:glue-esp>
    $<TARGET_OBJECTS:glue-debug>
    $<TARGET_OBJECTS:lwipcore>
)

# TODO: default DESTINATION is `lib/`, which is then prefixed with {CMAKE_INSTALL_PREFIX}
#       empty string results in the default `lib/`

# TODO: this will install to just prefix, but the actual path will be with a dot:
# install(TARGETS ${GLUE_VARIANT_NAME} ARCHIVE DESTINATION ".")
#
# For example:
# $ make lwip1460
# ... building ...
# [100%] Built target lwip2-1460
# Install the project...
# -- Install configuration: ""
# -- Installing: /home/builder/esp82xx-nonos-linklayer/output/./liblwip2-1460.a

install(TARGETS ${GLUE_VARIANT_NAME} ARCHIVE)
