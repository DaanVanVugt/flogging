# create shared library
# note that the position independent code flag is automatically appended
add_library(
        Flogging
        SHARED
        flogging.f90
        vt100.f90
)

# create namespaced alias for direct use
add_library(Flogging::Flogging ALIAS Flogging)

# add header file
# as a normal include if we are building the lib
# or as an interface if we use the built lib
target_include_directories(
        Flogging
        PUBLIC
                "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
        INTERFACE
                $<INSTALL_INTERFACE:include>
)

set_target_properties(
        Flogging
        PROPERTIES
                Fortran_PREPROCESS ON
                OUTPUT_NAME "flogging"
)

target_compile_definitions(
        Flogging
        PRIVATE
                $<$<BOOL:${USE_MPI}>:USE_MPI>
)

target_link_libraries(
        Flogging
        PUBLIC
                $<$<BOOL:${USE_MPI}>:MPI::MPI_Fortran>
)

# install instructions for library
install(
        TARGETS
                Flogging
        DESTINATION lib
        EXPORT FloggingTargets
)

# install instructions for header and Fortran module
install(
        FILES
                "${PROJECT_SOURCE_DIR}/include/flogging.h"
                "${CMAKE_Fortran_MODULE_DIRECTORY}/flogging.mod"
        DESTINATION include
)
