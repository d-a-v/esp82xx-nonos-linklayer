
# lwIP-2 from original source

This repo offers a link layer for esp82xx NONOS SDK 2 and 3.
The original goal is to try and use a recent lwIP version for stability reasons.
Currently only lwIP is implemented, but it is technically possible to use some other IP stack.

lwIP version currently used: [STABLE\_2.1.3](http://git.savannah.nongnu.org/cgit/lwip.git/tree/?h=STABLE-2_1_3_RELEASE)

# Status

* used by default in esp8266 arduino core ([initial pull request](https://github.com/esp8266/Arduino/pull/3783))
* TCP is more stable ([example1](https://github.com/esp8266/Arduino/issues/3075) and [example2](https://github.com/esp8266/Arduino/issues/2925))
* UDP/TCP codes using lwIP-1.4 need some updates - two examples: [arduino](https://github.com/esp8266/Arduino/pull/3129) and [sming](https://github.com/SmingHub/Sming/pull/1147)
* [IPv6 working in Arduino](https://github.com/esp8266/Arduino/pull/5136)
* [SACK-out enabled in Arduino](https://github.com/esp8266/Arduino/pull/5126)
* NAT support (patch for lwIP-2.1.2, based on previous works, check in `patches/`)
* [esp-open-sdk fork with lwip2](https://github.com/someburner/esp-open-sdk) ([oldref](https://github.com/pfalcon/esp-open-sdk/pull/271))

# Build & install

- `gmake lwip` to fetch & checkout the latest lwIP 2 and then patch them
- `gmake install` to build and install lwIP 2
  Make sure that `xtensa-lx106-elf-gcc` and `xtensa-lx106-elf-ar` are callable and are in `PATH`
  Optionally, update `CC` and `AR` instead of `PATH`

  `gmake CONFIG=... install` to select a different configuration:
  - [`arduino`](makefiles/config/arduino.mk) (default)
  - [`open`](makefiles/config/open.mk)

Alternatively, build with [`CMake`](README-CMake.md)

## Arduino

- Install the [git version](https://arduino-esp8266.readthedocs.io/en/stable/installing.html#using-git-version) of the esp8266 arduino core
- Download Xtensa toolchain by running [`tools/get.py --tool xtensa-lx106-elf`](https://github.com/esp8266/Arduino/blob/master/tools/get.py)
- Head to [`tools/sdk/lwip2/`](https://github.com/esp8266/Arduino/tree/master/tools/sdk/lwip2) and run `gmake` to update static libraries and headers

## PlatformIO

- Install Arduino [git version](https://docs.platformio.org/en/latest/platforms/espressif8266.html#using-arduino-framework-with-staging-version)
- Try to build a project using git version platform package at least once.
  Inspect `pio run --verbose` output to find out the location of `framework-arduinoespressif8266` and `toolchain-xtensa` packages.
  Update `PATH` environment variable to include `toolchain-xtensa` binaries directory *or* set tools location through environment variables:
  - `export PATH="/path/to/.platformio/packages/toolchain-xtensa/bin/:${PATH}`
- Run `gmake lwip` and `gmake install` from the root of this repo

# MSS

The lowest recommended value is 536. Currently supported targets build 536 and 1460 variants.

Remember the MSS footprint: 4×MSS bytes in RAM per tcp connection.

# How it works

Espressif binary blobs can only use lwIP 1.4 functions. The idea, as
described in this [comment](https://github.com/kadamski/esp-lwip/issues/8)
is to provide compatibility layer and translate lwIP 1.4 function call into a lwIP 2 one.

For example, this is lwIP 1.4 ethernet_input() called by espressif binary blobs
finally reaching lwIP 2 implementation.

```
Espressif blobs
        |
        | wifi stack calls ethernet_input()
        v
Glue lwIP 1.4 compatibility layer
  ethernet_input()
  converts lwIP 1.4 structures into glue structures
        |
        | calls glue_ethernet_input()
        v
Glue translation layer
  glue_ethernet_input()
  converts glue structures into lwIP 2 structures
        |
        | calls ethernet_input_LWIP2()
        v
lwIP 2
  ethernet_input_LWIP2()
  symbol is renamed from ethernet_input to ethernet_input_LWIP2
```

list of functions which are renamed from lwIP 2 side
- [`arch/cc.h`](glue-lwip/arch/cc.h)
  this file is included when building lwIP 2 and by the applications
  for example, `#define ethernet_input ethernet_input_LWIP2`

espressif's lwIP 1.4 options header, included when building compatiblity layer
- [`lwip-1.4-arduino/lwipopts.h`](glue-esp/lwip-1.4-arduino/lwipopts.h)

lwIP 2 options header, included when building lwIP 2 and applications
- [`arduino/lwipopts.h`](glue-lwip/arduino/lwipopts.h)

lwIP 1.4 compatibility layer
- [`glue-esp/glue-esp.c`](glue-esp/glue-esp.c)

lwIP 1.4 <-> 2 translation layer
- [`glue-lwip/lwip-git.c`](glue-lwip/glue-lwip.c)

# History

Original [cleaning and port](https://github.com/nekromant/esp8266-frankenstein/tree/master/src/contrib/lwipupdate) of espressif's patch set from lwIP 1.4 to lwIP 2 with references to lwIP-git-sha1

[Discussion](https://github.com/kadamski/esp-lwip/issues/8) on how further work could be done

[First](https://github.com/d-a-v/esp8266-phy) version of this implementation

[Second](https://github.com/esp8266/Arduino/pull/3206) version for arduino only
