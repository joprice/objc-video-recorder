
cmake_minimum_required(VERSION 3.0.2)

project(objc-test)

add_executable(objc-test main.m VideoRecorder.m)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -framework AppKit -framework AVFoundation -framework CoreMedia -framework CoreVideo")

set_property (TARGET objc-test APPEND_STRING PROPERTY COMPILE_FLAGS "-fobjc-arc -Wall -Wextra -Werror")

