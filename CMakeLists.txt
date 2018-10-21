cmake_minimum_required(VERSION 3.2)
project(UnicodeHpp)

include(cmake/c++-standards.cmake)
include(cmake/code-coverage.cmake)
include(cmake/sanitizers.cmake)
include(cmake/tools.cmake)

file(GLOB_RECURSE ALL_CXX_SOURCE_FILES
    ${PROJECT_SOURCE_DIR}/src/*.[ch]pp
    ${PROJECT_SOURCE_DIR}/src/*.[ch]
)

cxx_11()

add_executable(UnicodeHpp src/unicode_cpp_generator.cpp)
target_include_directories(UnicodeHpp PUBLIC ext)
target_code_coverage(UnicodeHpp AUTO)