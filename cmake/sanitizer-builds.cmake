# MIT License
#
# Copyright (c) 2018 George Cave
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

function(_CheckUnix)
    if (NOT UNIX)
        message(FATAL_ERROR "Error: ${ARGV0} requires a Unix environment.")
    endif()
endfunction()

function(_CheckClang)
    if (NOT (CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
        message(FATAL_ERROR "Error: ${ARGV0} requires the clang compiler.")
    endif()
endfunction()

# Build Types
message("Current build type is: ${CMAKE_BUILD_TYPE}")
SET(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} 
    CACHE STRING "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel tsan asan lsan msan ubsan."
    FORCE)

# ThreadSanitizer
set(CMAKE_C_FLAGS_TSAN
    "-fsanitize=thread -g -O1"
    CACHE STRING "Flags used by the C compiler during ThreadSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_TSAN
    "-fsanitize=thread -g -O1"
    CACHE STRING "Flags used by the C++ compiler during ThreadSanitizer builds."
    FORCE)

# AddressSanitize
set(CMAKE_C_FLAGS_ASAN
    "-fsanitize=address -fno-optimize-sibling-calls -fsanitize-address-use-after-scope -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C compiler during AddressSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_ASAN
    "-fsanitize=address -fno-optimize-sibling-calls -fsanitize-address-use-after-scope -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C++ compiler during AddressSanitizer builds."
    FORCE)

# LeakSanitizer
set(CMAKE_C_FLAGS_LSAN
    "-fsanitize=leak -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C compiler during LeakSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_LSAN
    "-fsanitize=leak -fno-omit-frame-pointer -g -O1"
    CACHE STRING "Flags used by the C++ compiler during LeakSanitizer builds."
    FORCE)

# MemorySanitizer
set(CMAKE_C_FLAGS_MSAN
    "-fsanitize=memory -fno-optimize-sibling-calls -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -g -O2"
    CACHE STRING "Flags used by the C compiler during MemorySanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_MSAN
    "-fsanitize=memory -fno-optimize-sibling-calls -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -g -O2"
    CACHE STRING "Flags used by the C++ compiler during MemorySanitizer builds."
    FORCE)

# UndefinedBehaviour
set(CMAKE_C_FLAGS_UBSAN
    "-fsanitize=undefined"
    CACHE STRING "Flags used by the C compiler during UndefinedBehaviourSanitizer builds."
    FORCE)
set(CMAKE_CXX_FLAGS_UBSAN
    "-fsanitize=undefined"
    CACHE STRING "Flags used by the C++ compiler during UndefinedBehaviourSanitizer builds."
    FORCE)

    if(CMAKE_BUILD_TYPE STREQUAL "tsan")
    # Thread Sanitizer
    message("Building for ThreadSanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)

elseif(CMAKE_BUILD_TYPE STREQUAL "asan")
    # Address Sanitizer (also Leak Sanitizer)
    message("Building for AddressSanitizer (with LeakSanitizer)")
    _CheckUnix()

elseif(CMAKE_BUILD_TYPE STREQUAL "lsan")
    # Leak Sanitizer (Standalone)
    message("Building for LeakSanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)

elseif(CMAKE_BUILD_TYPE STREQUAL "msan")
    # Memory Sanitizer
    message("Building for MemorySanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)
    _CheckClang(CMAKE_BUILD_TYPE)

elseif(CMAKE_BUILD_TYPE STREQUAL "ubsan")
    # Undefined Behaviour Sanitizer
    message("Building for UndefinedBehaviourSanitizer")
    _CheckUnix(CMAKE_BUILD_TYPE)

else()
    if(UNIX)
        # If running on Linux, then enable the build types for the clang-based sanitizer tools
        message("On Unix, there are extra build configurations:")
        message("tsan: ThreadSanitizer")
        message("asan : AddressSanitizer")
        message("lsan : LeakSanitizer")
        message("msan : MemorySanitizer (Clang only)")
        message("ubsan : UndefinedBehaviourSanitizer")
    else()
        message("To enable sanitizer tools, run in a Unix environment.")
    endif()
endif()