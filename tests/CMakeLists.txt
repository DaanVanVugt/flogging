# there is one test file for normal build and one test file for MPI build
# both cannot be compiled at the same time
add_executable(
        log-test
        $<$<BOOL:${USE_MPI}>:test_mpi.f90>
        $<$<NOT:$<BOOL:${USE_MPI}>>:test.f90>
)

set_target_properties(
        log-test
        PROPERTIES
                Fortran_PREPROCESS ON
)

target_link_libraries(
        log-test
        PRIVATE
                flogging
                $<$<BOOL:${USE_MPI}>:MPI::MPI_Fortran>
)

add_test(
        NAME
                log-test
        COMMAND
                log-test
        WORKING_DIRECTORY
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
)
