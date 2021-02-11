# there is one test for normal build and one test for MPI build
# both cannot be compiled at the same tame
if(NOT USE_MPI)
        add_executable(
                log-test
                test.f90
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
        )

        add_test(
                NAME
                        log-test
                COMMAND
                        log-test
                WORKING_DIRECTORY
                        "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
        )
else()
        add_executable(
                log-test-mpi
                test_mpi.f90
        )

        set_target_properties(
                log-test-mpi
                PROPERTIES
                        Fortran_PREPROCESS ON
        )

        target_link_libraries(
                log-test-mpi
                PRIVATE
                        flogging
                        MPI::MPI_Fortran
        )

        add_test(
                NAME
                        log-test-mpi
                COMMAND
                        log-test-mpi
                WORKING_DIRECTORY
                        "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
        )
endif()
