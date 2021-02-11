cmake_minimum_required(VERSION 3.1.0)

project(
        Flogging
        VERSION 1.0.0
        LANGUAGES Fortran
)

# append custom CMake modules directory
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/Modules")

# set destination for binaries, libraries, Fortran modules and generated doc
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_BINARY_DIR}/modules")
set(CMAKE_DOC_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/doc")

# imports
find_package(MPI)

# import standard CMake modules
include(CMakePackageConfigHelpers)

# import custom CMake modules
include(Install)
include(Options)

add_subdirectory(src)
add_subdirectory(doc EXCLUDE_FROM_ALL)

if(BUILD_TESTING)
        enable_testing()
        add_subdirectory(tests)
endif()
