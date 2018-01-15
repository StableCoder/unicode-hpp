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

# Code Coverage
option(CODE_COVERAGE "Builds targets with code coverage tools (Requires llvm and Clang)." OFF)

if(CODE_COVERAGE)
    message("Building with Code Coverage Tools")
    if (NOT UNIX OR NOT (CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
        message(FATAL_ERROR "Error: CODE_COVERAGE option requires a unix environment and clang compiler.")
    endif()
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
endif()

# Replacement for add_library that adds code coverage targets automatically.
#
# Takes in the same options as a regular add_library command, however adds two targets
# named '${ARGV0}-ccov-show' and '${ARGV0}-ccov-report', aswell as the pooled end target of
# 'ccov-report', except for non-compilable interface libraries.
macro(_AddLibrary)
    add_library(${ARGN})

    # Make sure not an interface library
    get_target_property(_TARGET_TYPE ${PROJECT_NAME} TYPE)
    if(CODE_COVERAGE AND NOT _TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
        add_custom_target(${ARGV0}-ccov-preprocessing
            COMMAND LLVM_PROFILE_FILE=${ARGV0}.profraw $<TARGET_FILE:${ARGV0}>
            COMMAND llvm-profdata merge -sparse ${ARGV0}.profraw -o ${ARGV0}.profdata
            DEPENDS ${ARGV0})

        add_custom_target(${ARGV0}-ccov-show
            COMMAND llvm-cov show $<TARGET_FILE:${ARGV0}> -instr-profile=${ARGV0}.profdata -show-line-counts-or-regions
            DEPENDS ${ARGV0}-ccov-preprocessing)

        add_custom_target(${ARGV0}-ccov-report
            COMMAND llvm-cov report $<TARGET_FILE:${ARGV0}> -instr-profile=${ARGV0}.profdata
            DEPENDS ${ARGV0}-ccov-preprocessing)

        if(NOT TARGET ccov-report)
            add_custom_target(ccov-report)
        endif()

        add_dependencies(ccov-report ${ARGV0}-ccov-report)
    endif()
endmacro()

# Replacement for add_executable that adds code coverage targets automatically.
#
# Takes in the same options as a regular add_library command, however adds two targets
# named '${ARGV0}-ccov-show' and '${ARGV0}-ccov-report', aswell as the pooled end target of
# 'ccov-report'.
macro(_AddExecutable)
    add_executable(${ARGN})

    if(CODE_COVERAGE)
        add_custom_target(${ARGV0}-ccov-preprocessing
            COMMAND LLVM_PROFILE_FILE=${ARGV0}.profraw $<TARGET_FILE:${ARGV0}>
            COMMAND llvm-profdata merge -sparse ${ARGV0}.profraw -o ${ARGV0}.profdata
            DEPENDS ${ARGV0})

        add_custom_target(${ARGV0}-ccov-show
            COMMAND llvm-cov show $<TARGET_FILE:${ARGV0}> -instr-profile=${ARGV0}.profdata -show-line-counts-or-regions
            DEPENDS ${ARGV0}-ccov-preprocessing)

        add_custom_target(${ARGV0}_ccov-report
            COMMAND llvm-cov report $<TARGET_FILE:${ARGV0}> -instr-profile=${ARGV0}.profdata
            DEPENDS ${ARGV0}-ccov-preprocessing)

        if(NOT TARGET ccov-report)
            add_custom_target(ccov-report)
        endif()

        add_dependencies(ccov-report ${ARGV0}_ccov-report)
    endif()
endmacro()