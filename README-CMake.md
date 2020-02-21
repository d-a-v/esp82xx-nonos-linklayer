# Building

- Follow the `git` version installation instructions from the [**Build** section of the README](README.md#Build)
- Ensure that the toolchain is installed (Run `tools/get.py` for Arduino IDE, run `pio platform install ...` for PlatformIO)
- Head to [tools/sdk/lwip2/](https://github.com/esp8266/Arduino/tree/master/tools/sdk/lwip2)
- To build & install everything into the selected ESP8266 Core directory:

When using Arduino IDE:
```
$ mkdir build ; cd build
$ cmake ../
$ cmake --build .
```

When using PlatformIO:
```
$ cmake -DESP8266_TOOLCHAIN_PATH=<path-to-the-toolchain-xtensa-package> ../
$ cmake --build .
```

Or, just to build a single variant:
```
$ cmake --build . --target lwip2-1460
```

Run `cmake --build . --target help` to list all of the available targets.

# Windows

If you are using Windows and can't (or don't want to) use [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) / [WSL2](https://docs.microsoft.com/en-us/windows/wsl/wsl2-install) to run the build in the Unix environment, you would need to install the latest C++ development package:

- Download the Visual Studio Installer at https://visualstudio.microsoft.com/
- In addition to the core package, install C++ dev tools (~7GB in size total)
- Run in "Native Tools Command Prompt for Visual Studio":
```
> cmake -G "Ninja" ../
> cmake --build .
```
Or, using NMake generator:
```
> cmake -G "NMake Makefiles" ../
> cmake --build .
```

# Maintainer notice

To build `<GLUE_VARIANT_NAME>`

- `cmake/variants/<GLUE_VARIANT_NAME>/CMakeLists.txt` must exist
- It should follow this template:

```cmake
cmake_minimum_required(VERSION 3.9)
project(<GLUE_VARIANT_NAME> LANGUAGES C)

set(TCP_MSS ...)
set(LWIP_IPV6 ...)
set(LWIP_FEATURES ...)

include(lwip-builder)
```
