cmake_minimum_required(VERSION 3.11)
project(lwip-glue-builder
    VERSION 20220711
    DESCRIPTION "lwip-glue-builder"
    LANGUAGES C
)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 11)

add_compile_options(
    -nostdlib
    -ffunction-sections
    -fdata-sections
    -falign-functions=4)

add_compile_options(
    -Wall
    -Wextra
    -Wpointer-arith
    -Werror=return-type)

add_compile_options(
    -Os
    -g)

set(UPSTREAM_VERSION "STABLE-2_1_3_RELEASE")
set(LWIP_TAG ${UPSTREAM_VERSION})

# TODO: never assume this is in-tree of esp8266/Arduino, force to give some path
set(ESP8266_ARDUINO_CORE_DIR "" CACHE FILEPATH "Arduino Core default path")
if (NOT EXISTS ${ESP8266_ARDUINO_CORE_DIR})
    message(SEND_ERROR ${ESP8266_ARDUINO_CORE_DIR})
    message(FATAL_ERROR "Core directory does not exist")
endif()
message(STATUS "core dir: " "${ESP8266_ARDUINO_CORE_DIR}")

# fetches lwip2-src into the current build directory, then automatically patches it

file(GLOB LWIP_PATCHES ${CMAKE_SOURCE_DIR}/patches/*.patch)
message(STATUS "patches: " "${LWIP_PATCHES}")

# TODO: GIT_CONFIG needed for windows install. lwip.git repo classifies .h as text through .gitattributes, and git-clone will apply native eol conversion
# by default, git does not attribute .h files as text, so when installing .h into the esp8266 repo it will make them differ when all that's different is eol
include(FetchContent)
FetchContent_Declare(
    lwip2
    GIT_REPOSITORY https://git.savannah.nongnu.org/git/lwip.git
    GIT_TAG ${LWIP_TAG}
    GIT_CONFIG core.autocrlf=false core.eol=lf
    PATCH_COMMAND git reset --hard && git clean -f && git apply --3way --recount --whitespace=fix ${LWIP_PATCHES}
)

FetchContent_MakeAvailable(lwip2)
FetchContent_GetProperties(lwip2 SOURCE_DIR)
set(LWIP_DIR ${lwip2_SOURCE_DIR})

message(STATUS "lwip dir: " "${LWIP_DIR}")
message(STATUS "lwip tag: " "${LWIP_TAG}")

# the actual builder consists of a glue_variant(NAME DEFINITIONS), which will add a library target to build the actual sources
# from the glue, glue-esp and the lwip2-src
include(cmake/lwip-builder.cmake)

glue_variant(
    NAME lwip2-1460
    DEFINITIONS -DTCP_MSS=1460 -DLWIP_FEATURES=0 -DLWIP_IPV6=0
)
glue_variant(
    NAME lwip2-1460-feat
    DEFINITIONS -DTCP_MSS=1460 -DLWIP_FEATURES=1 -DLWIP_IPV6=0
)

glue_variant(
    NAME lwip2-536
    DEFINITIONS -DTCP_MSS=536 -DLWIP_FEATURES=0 -DLWIP_IPV6=0
)
glue_variant(
    NAME lwip2-536-feat
    DEFINITIONS -DTCP_MSS=536 -DLWIP_FEATURES=1 -DLWIP_IPV6=0
)

glue_variant(
    NAME lwip6-536
    DEFINITIONS -DTCP_MSS=536 -DLWIP_FEATURES=1 -DLWIP_IPV6=1
)
glue_variant(
    NAME lwip6-1460
    DEFINITIONS -DTCP_MSS=1460 -DLWIP_FEATURES=1 -DLWIP_IPV6=1
)
