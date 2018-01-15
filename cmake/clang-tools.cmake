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

#file(GLOB_RECURSE ALL_CODE_FILES
#    ${PROJECT_SOURCE_DIR}/src/*.[ch]pp
#    ${PROJECT_SOURCE_DIR}/src/*.[ch]
#    ${PROJECT_SOURCE_DIR}/include/*.[h]pp
#    ${PROJECT_SOURCE_DIR}/include/*.[h]
#)

#get_target_property(_TARGET_TYPE ${PROJECT_NAME} TYPE)
#if(NOT _TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
#   ...
#endif()

# Generates a 'format' target using a custom name, files, and include directories all being parameters.
#
# TIDY_TARGET_NAME - The name of the target to create
# ARGN - The list of files to format
macro(_ClangFormat FORMAT_TARGET_NAME)
    if(NOT CLANG_FORMAT)
        find_program(CLANG_FORMAT "clang-format")
    endif()
    if(CLANG_FORMAT)
        add_custom_target(
            ${FORMAT_TARGET_NAME}_format
            COMMAND clang-format
            -i
            -style=file
            ${ARGN}
        )

        if(NOT TARGET format)
            add_custom_target(format)
        endif()

        add_dependencies(format ${FORMAT_TARGET_NAME}_format)
    endif()
endmacro()

# Generates a 'tidy' target using a custom name, files, and include directories all being parameters.
#
# TIDY_TARGET_NAME - The name of the target to create
# ARGN - The list of files to process, and any items prefixed by '-I' will become an include directory instead.
macro(_ClangTidy TIDY_TARGET_NAME)
    if(NOT CLANG_TIDY)
        find_program(CLANG_TIDY "clang-tidy")
    endif()
    if(CLANG_TIDY)
        # Clear the vars
        set(TIDY_CODE_FILES "")
        set(TIDY_INCLUDE_DIRS "")
        # Go through the parameters and figure out which are code files and which are include directories
        set(params "${ARGN}")
        foreach(param IN LISTS params)
            string(SUBSTRING ${param} 0 2 TIDY_TEMP_STRING)
            if(TIDY_TEMP_STRING STREQUAL "-I")
                set(TIDY_INCLUDE_DIRS "${TIDY_INCLUDE_DIRS}" "${param}")
            else()
                set(TIDY_CODE_FILES "${TIDY_CODE_FILES}" "${param}")
            endif()
        endforeach()

        if(NOT TIDY_CODE_FILES STREQUAL "")
            add_custom_target(
                ${TIDY_TARGET_NAME}_tidy
                COMMAND clang-tidy
                ${TIDY_CODE_FILES}
                -format-style=file
                --
                -std=c++${CMAKE_CXX_STANDARD}
                ${TIDY_INCLUDE_DIRS}
            )

            if(NOT TARGET tidy)
                add_custom_target(tidy)
            endif()

            add_dependencies(tidy ${TIDY_TARGET_NAME}_tidy)
        endif()
    endif()
endmacro()