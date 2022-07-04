include(Compiler/GNU)

set(CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/esp8266-platform.cmake")
set(CMAKE_SYSTEM_NAME "Generic")

set(triple xtensa-lx106-elf)

set(CMAKE_C_COMPILER ${triple}-gcc)
set(CMAKE_CXX_COMPILER ${triple}-g++)

list(APPEND compile_options
    "-nostdlib"
    "-mlongcalls"
    "-mtext-section-literals"
    "-ffunction-sections"
    "-fdata-sections"
    "-falign-functions=4")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
