# STM32F4DISC RTE

This is a simple "Makefication" of [RTE](https://github.com/nucleron/RTE) nucleron project focused in [TONFIT board](https://github.com/iotontech).

# Configuring the environment to build

> This commands was tested just in 16.04.1-Ubuntu

The ficticious variable **${TONFIT_RTE_ROOT}** indicates the current directory where all tools described here is download


* Create the ${TONFIT_RTE_ROOT} directory

```shell
$ mkdir tonfit_rte  
$ cd tonfit_rte  
```

* Clone this project

```
$ git clone https://github.com/libopencm3/libopencm3.git
```

* Download the arm toolchain

> This code was tested just with GNU Arm Embedded Toolchain 4.9-2015-q3-update

```shell
$ wget https://launchpad.net/gcc-arm-embedded/4.9/4.9-2015-q3-update/+download/gcc-arm-none-eabi-4_9-2015q3-20150921-linux.tar.bz2
```

* Clone matiec project


```shell
$ hg clone ssh://hg@bitbucket.org/mjsousa/matiec
```

* Clone libopencm3 project

```shell
$ git clone https://github.com/libopencm3/libopencm3.git
```

* Untar the ARM gcc toolchain and export the binaries to PATH

```shell
$ tar -xvf gcc-arm-none-eabi-7-2017-q4-major-linux.tar.bz2  
$ export PATH=$PWD/gcc-arm-none-eabi-7-2017-q4-major/bin/:$PATH  
$ arm-none-eabi-gcc --version  
```

* Build the libopencm3

```shell
$ cd libopencm3/  
$ make  
$ cd ..  
```

* Set some enviromnent variable to build this project

> You need to be in the ${TONFIT_RTE_ROOT} directory to execute this commands


```shell
$ export LIBOPENCM3_DIR=$PWD/libopencm3  
$ export MATIEC_C_INCLUDE_DIR=$PWD/matiec/lib/C  
$ export ARM_GCC_TOOLCHAIN_DIR=$PWD/gcc-arm-none-eabi-4_9-2015q3
$ export STM32FLASH_DIR=$PWD/stm32flash
``` 

* Build the project

The build will generate the .elf and .hex that can be upload to the f4disc board using dfu-util, stlink, openocd, etc...

```
$ cd tonfit_rte  
$ make
```

* Flash the project

You will need some USB-TTL Conversor and connect the pins as bellow:

```
TONFIT PIN 30 -> Connect to RX pin of USB to Serial TTL 
TONFIT PIN 29 -> Connect to TX pin of USB to Serial TTL
TONFIT GND	  -> USB to Serial TTL GND
```

Enter in the tonfit rte project directory cloned with git.

> Check the usb device created by linux to your USB to Serial Converter and check the `flash_hex` target in the makefile to match with it

```shell
$ cd tonfit_rte
$ make flash_hex
```

After flash the RGB led in the board will blink waiting you transfer some code using the [YAPLC/IDE](https://github.com/nucleron/IDE)




