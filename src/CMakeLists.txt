# create shared library
# note that the position independent code flag is automatically appended
add_library(
        flogging
        SHARED
        flogging.f90
        vt100.f90
)

# add header file
# as a normal include if we are building the lib
# or as an interface if we use the built lib
target_include_directories(
        flogging
        PUBLIC
                "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>"
        INTERFACE
                "$<INSTALL_INTERFACE:include>"
)

set_target_properties(
        flogging
        PROPERTIES
                Fortran_PREPROCESS ON
)

# special rules for MPI build
if(USE_MPI)
        target_compile_definitions(
                flogging
                PRIVATE
                        USE_MPI
        )

        target_link_libraries(
                flogging
                PUBLIC
                        MPI::MPI_Fortran
        )
endif()

# install instructions for library
install(
        TARGETS
                flogging
        DESTINATION lib
        EXPORT FloggingTargets
)

# install instructions for header
install(
        FILES
                "${CMAKE_SOURCE_DIR}/include/flogging.h"
        DESTINATION include
)

# install instructions for Fortran module
install(
        FILES
                "${CMAKE_Fortran_MODULE_DIRECTORY}/flogging.mod"
        DESTINATION include
)
