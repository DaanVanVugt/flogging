test : logging.f90 test_log.f90 vt100.f90 logging.h
	mpifort -Wall -cpp vt100.f90 logging.f90 test_log.f90 -o test
