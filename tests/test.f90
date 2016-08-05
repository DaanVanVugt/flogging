#include "flogging.h"
program test_log
  use flogging

  implicit none
  ! This is an example program showing logging with different levels( filenames and mpi

  log_error(*) "this is an error"
  log_warn(*) "this is a warning"
  log_info(*) "here( have some info"
  log_debug(*) "and this is a debug message"

  log_debug(*) "and this is a debug message 2"
  log_error(*) "this is a warning"

  ! Enable date output
  call log_set_output_date(.true.)
  log_error(*) "Error from thread 0 with date"

end program
