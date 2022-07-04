include(Compiler/GNU)

set(CMAKE_SYSTEM_NAME "xtensa")
set(CMAKE_SYSTEM_PROCESSOR "lx106")

set(triple xtensa-lx106-elf)

set(CMAKE_C_COMPILER gcc)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER g++)
set(CMAKE_CXX_COMPILER_TARGET ${triple})

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
