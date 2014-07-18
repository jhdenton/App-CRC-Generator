App-CRC-Generator
=================

Ruby script to generate CRC(s) of application memory space(s) from hex file.

This started as a way to automate CRC generation for a specific dsPIC project. Over time I hope to generalize into Intel Hex and CRC libraries that can be used in a variety of situaltions.



crc_gen.rb - Main Ruby script/source

crc-gen.exe - OCRA generate self-contained Windows executable (added to my toolchain so that CRC is check and reported as part of builds.

dspic-example.hex - The Intel Hex file I used for development/testing. The dsPIC has a peculiar addressing where three of each four bytes in the hex file are mapped into each "word" of memory. e.g. Hex file data at 0x00400-0x00401 gets put into physical memory at 0x0200-0x0201, 0x00402 gets put into a "hidden" high word tied to 0x200, and 0x00403 is ignored.

README.md - This file

.gitignore - .gitignore

