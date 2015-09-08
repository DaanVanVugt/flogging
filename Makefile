test : log.f90 test_log.f90 vt100.f90 logging.h
	gfortran -Wall -cpp vt100.f90 log.f90 test_log.f90 -o test
