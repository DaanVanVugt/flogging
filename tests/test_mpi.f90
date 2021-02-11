#include "flogging.h"
program test_log
  use flogging
  use mpi

  implicit none
  integer :: ierr
  ! This is an example program showing logging with different levels( filenames and mpi

  call MPI_Init(ierr)

  log_error(*) "help we had an error"
  log_root_warn(*) &
    "this is a warning with a filename"
  log_root_info(*) &
    "here have some info with a filename"
  log_root_debug(*) &
    "and this is a debug message"
  log_root_debug(*) &
    "and this is a debug message 2"
  log_root_error(*) "this is a warning"

  ! Enable date output
  call log_set_output_date(.true.)
  log_root_error(*) &
    "Error from thread 0 with date"

  call MPI_Finalize(ierr)
end program
