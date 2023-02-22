###############################################################################
#                                                                             #
#                             CMake configuration                             #
#                                                                             #
###############################################################################

cmake_minimum_required(VERSION 3.1...3.15)

if(${CMAKE_VERSION} VERSION_LESS 3.12)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
endif()



###############################################################################
#                                                                             #
#                                   Toggles                                   #
#                                                                             #
###############################################################################

option(BUILD_STATIC_LIBS "Build libraries as static libraries" OFF)
option(BUILD_RELEASE "Whether to build for a debug or release profile" OFF)

if(${BUILD_STATIC_LIBS} OR WIN32)
    set(STATIC_OR_SHARED "STATIC")
else()
    set(STATIC_OR_SHARED "SHARED")
endif()



###############################################################################
#                                                                             #
#                              Compiler options                               #
#                                                                             #
###############################################################################

set(CMAKE_CXX_STANDARD 20)

if (NOT ${BUILD_RELEASE})
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} /Od")
    endif()
endif()

if(CMAKE_COMPILER_IS_GNUCC)
endif()



###############################################################################
#                                                                             #
#                             Project definition                              #
#                                                                             #
###############################################################################

# Project general info
set(<PROJECT_NAME> "<Project Name>")

project(
    ${<PROJECT_NAME>}
    VERSION "1.0"
    DESCRIPTION "<Project Description>"
    LANGUAGES C CXX
)


###############################################################################
#                                                                             #
#                              Build executable                               #
#                                                                             #
###############################################################################

# Build executable
add_executable("<project_name>"
    <project_name>/main.cpp
    <project_name>/main.hpp
)

target_include_directories("<project_name>" PUBLIC external/include/)
target_link_directories("<project_name>" PUBLIC external/lib/)

target_link_libraries("<project_name>" PUBLIC ${CMAKE_DL_LIBS} -v) 
