# flag to use MPI
option(
        USE_MPI
        "Build using MPI"
)

if(NOT MPI_FOUND AND USE_MPI)
        message(FATAL_ERROR "MPI requested but not found")
endif()

# flag to build tests
option(
        BUILD_TESTING
        "Build tests"
)
