test : flogging.f90 test.f90 vt100.f90 logging.h
	mpifort -Wall -cpp vt100.f90 flogging.f90 test.f90 -o test

test_mpi : flogging.f90 test_mpi.f90 vt100.f90 logging.h
	mpifort -Wall -cpp -DUSE_MPI vt100.f90 flogging.f90 test_mpi.f90 -o test_mpi
