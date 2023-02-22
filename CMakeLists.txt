cmake_minimum_required( VERSION 3.1...3.15 )

set( CMAKE_CXX_STANDARD 20 )

# Project general info
project(
    "<Project Name>"
    VERSION "1.0"
    DESCRIPTION "<Project Description>"
    LANGUAGES C CXX
)

# Build executable
add_executable( "<project_name>"
    <project_name>/main.cpp
    <project_name>/main.hpp
)

target_include_directories( "<project_name>" PUBLIC <project_name> )
target_link_libraries( "<project_name>" PUBLIC ${CMAKE_DL_LIBS} -v )
