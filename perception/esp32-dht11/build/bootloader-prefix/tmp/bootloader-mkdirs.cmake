# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/home/iiot/esp/esp-idf/components/bootloader/subproject"
  "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader"
  "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix"
  "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix/tmp"
  "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix/src/bootloader-stamp"
  "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix/src"
  "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix/src/bootloader-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix/src/bootloader-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/home/iiot/ceiot_base/perception/esp32-dht11/build/bootloader-prefix/src/bootloader-stamp${cfgdir}") # cfgdir has leading slash
endif()
