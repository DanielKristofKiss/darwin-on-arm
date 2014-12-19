SHELL := /bin/bash

FORCE:

current_dir := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

export PATH := $(current_dir)/dtc-AppleDeviceTree:$(PATH)

dtc: FORCE
	$(info BUILD dtc)
	@cd dtc-AppleDeviceTree;make;chmod +x dtc

image3maker: FORCE
	$(info BUILD image3maker)
	@cd image3maker; make; chmod +x image3maker

DeviceTrees: dtc
	$(info BUILD deviceTrees)
	@cd DeviceTrees; make;

xnu: FORCE
	$(info BUILD xnu)
	@cd xnu; make TARGET_CONFIGS="debug arm armpba8"

RamImage:
	

prepareImages: xnu DeviceTrees RamImage image3maker
	$(info BUILD images)
	@rm -f GenericBooter/images/Mach.img3
	@rm -f GenericBooter/images/DeviceTree.img3
	@rm -f GenericBooter/images/Ramdisk.img3
	@rm -f GenericBooter/vmlinux*
	@rm -f GenericBooter/uImage
	image3maker/image3maker --outputFile GenericBooter/images/Mach.img3 --imageTag krnl --dataFile xnu/BUILD/obj/DEBUG_ARM_ARMPBA8/mach_kernel
	image3maker/image3maker --outputFile GenericBooter/images/DeviceTree.img3 --imageTag dtre --dataFile DeviceTrees/RealView.devicetree
	image3maker/image3maker --outputFile GenericBooter/images/Ramdisk.img3 --imageTag rdsk --dataFile ramdisk/ramdisk.dmg

GenericBooter/.config: FORCE
	$(info moving default instead of make menuconfig for genericbooter)
	cp .config GenericBooter/

GenericBooter: prepareImages DeviceTrees image3maker GenericBooter/.config
	$(info BUILD GenericBooter)
	@cd GenericBooter;make CROSS_COMPILE=arm-none-eabi-;

all: GenericBooter

run: GenericBooter
	qemu-system-arm -machine realview-pb-a8 -m 512 -serial stdio -append "rd=md0 serial=3 -v -s -x symbolicate_panics=1" -kernel GenericBooter/uImage
