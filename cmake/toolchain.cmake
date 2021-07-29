include(Compiler/GNU)

set(CMAKE_USER_MAKE_RULES_OVERRIDE "${CMAKE_CURRENT_LIST_DIR}/esp8266-platform.cmake")
set(CMAKE_SYSTEM_NAME "Generic")

set(CMAKE_C_COMPILER xtensa-lx106-elf-gcc)
set(CMAKE_CXX_COMPILER xtensa-lx106-elf-g++)

set(CMAKE_C_FLAGS "-Wall -Wextra -c -Os -g -Wpointer-arith -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS "-Wall -Wextra -c -Os -g -Wpointer-arith -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -ffunction-sections -fdata-sections")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
