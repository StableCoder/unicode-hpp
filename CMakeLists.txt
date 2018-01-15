cmake_minimum_required(VERSION 3.2)
project(UnicodeHpp)

include(cmake/c++-standards.cmake)
include(cmake/clang-tools.cmake)
include(cmake/code-coverage.cmake)
include(cmake/sanitizer-builds.cmake)

file(GLOB_RECURSE ALL_CXX_SOURCE_FILES
    ${PROJECT_SOURCE_DIR}/src/*.[ch]pp
    ${PROJECT_SOURCE_DIR}/src/*.[ch]
)

_Cxx11()
_ClangFormat(UnicodeHpp ${ALL_CXX_SOURCE_FILES})
_ClangTidy(UnicodeHpp ${ALL_CXX_SOURCE_FILES})

# GCC
if(CMAKE_COMPILER_IS_GNUCXX AND NOT COMPILER_FLAGS_SET)
    set(COMPILER_FLAGS_SET ON)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Weffc++")
endif()

_AddExecutable(UnicodeHpp src/unicode_cpp_generator.cpp)
target_include_directories(UnicodeHpp PUBLIC ext)