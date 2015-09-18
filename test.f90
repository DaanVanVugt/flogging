#include "logging.h"
program test_log
  use flogging

  implicit none
  ! This is an example program showing logging with different levels, filenames and mpi

  log(crit,*) "help we had a critical error"
  log(err,*) "this is an error"
  log(warn,*) "this is a warning"
  log(info,*) "here, have some info"
  log(debug,*) "and this is a debug message"

  log(debug,*) "and this is a debug message 2"
  log(crit,*) "help we had an error"
  log(err,*) "this is a warning"

  ! Enable date output
  call log_set_default_output_date(.true.)
  log(err,*) "Error from thread 0 with line-info and mpi id and date"

end program
