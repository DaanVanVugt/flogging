test_debug : log.f90 test_log.f90 vt100.f90 logging.h
	gfortran -cpp vt100.f90 log.f90 test_log.f90 -DDEBUG=true -o test_debug

test : log.f90 test_log.f90 vt100.f90 logging.h
	gfortran -cpp vt100.f90 log.f90 test_log.f90 -o test

test_date : log.f90 test_log.f90 vt100.f90 logging.h
	gfortran -cpp vt100.f90 log.f90 test_log.f90 -DDEBUG=true -DLOG_DATE=true -o test_date
