# Building with CMake

- Follow the `git` version installation instructions from the [**Build** section of the README](README.md#Build)
- Ensure that the toolchain is installed (Run `tools/get.py` for Arduino IDE, run `pio platform install ...` for PlatformIO)
- Head to [tools/sdk/lwip2/](https://github.com/esp8266/Arduino/tree/master/tools/sdk/lwip2)
- `mkdir build && build`

When using Arduino IDE:
- `cmake ../`, the script will auto-detect all of the settings automatically

When using PlatformIO:
- `cmake -DESP8266_TOOLCHAIN_PATH=<path-to-the-toolchain-xtensa-package> ../`

See `make help` for all of the available targets.
Run `make` without arguments to build & install all.
