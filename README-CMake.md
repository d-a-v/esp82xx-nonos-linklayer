# Building

- Follow the `git` version installation instructions from the [**Build** section of the README](README.md#Build)
- Ensure that the toolchain is installed:
  - run `tools/get.py` for Arduino IDE so toolchain directory is created in the tools/ directory
  - run `pio platform install --with-package toolchain-xtensa espressif8266` for PlatformIO so the toolchain files are installed into the ~/.platformio/packages/toolchain-xtensa (or the versioned dir, depending on existing packages)


To build & install everything into the specific ESP8266 Core directory:
```
$ cmake \
    --toolchain=cmake/toolchain-esp8266.cmake \
    -DCMAKE_PROGRAM_PATH=<path to the gcc toolchain bin directory> \
    -DESP8266_ARDUINO_CORE_DIR=<path to the arduino core directory> \
    -B build
$ cmake --build build
$ cmake --install build --config Release
```

To build a single variant:
```
$ cmake --build <build directory> --target lwip2-1460
```

To build in parallel:
```
# cmake --build <build directory> --parallel <N>
```
The option specifies the maximum number of concurrent processes to use when building. If \<N\> is omitted the native build tool's default number is used.

Run `cmake --build <build directory> --target help` to list all of the available targets.

# Windows

## Windows Subsystem for Linux (WSL)

- Install the WSL environment by following the guide at https://docs.microsoft.com/en-us/windows/wsl/install-win10
- Install the Linux distribution (for the list, see the output of `wsl --list --online`)
- [Launch the distribution terminal and follow the instructions above](#Building)

## Using Windows Development Tools

- Download the Visual Studio Installer at https://visualstudio.microsoft.com/
- In addition to the core package, install C++ dev tools (~7GB in size total)
- Run in "Native Tools Command Prompt for Visual Studio":
```
> cmake -G "Ninja" -B build
```
Or, using NMake generator:
```
> cmake -G "NMake Makefiles" -B build
```

## Manually installing the tools

For example, to use ninja build system:
- Download and install the latest cmake package at https://cmake.org/download/
- Download the latest ninja package at https://github.com/ninja-build/ninja/releases
- Make sure both cmake.exe and ninja.exe locations are in PATH (or manually add them to the current powershell session via `$env:PATH+=";C:\Program Files\CMake\bin"`, or using the GUI controlling the environment variables).
- Configure the build using the Ninja generator:
```
> cmake -G "Ninja" -B build
```

# Maintainer notice

To add another variant, add `glue_variant(NAME <GLUE_VARIANT_NAME> DEFINITIONS <GLUE_VARIANT_DEFINITIONS>)` to the CMakeLists.txt. Notice that NAME must be unique.
