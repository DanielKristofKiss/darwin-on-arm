darwin-on-arm
=============

Put things together

Dependencies
==========
MAC OSX Yosemite ( or other versions )

MacPorts: https://www.macports.org/
    download + install
    then 
        sudo port install arm-none-eabi-gcc
        sudo port install qemu +target_arm
    
HomeBrew: http://brew.sh/
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
then 
     brew install u-boot-tools

Build and Run
==========

build
    make all

run
    make run

