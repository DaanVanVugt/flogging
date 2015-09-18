#include "logging.h"
program test_log
  use flogging
  use mpi

  implicit none
  integer :: ierr
  ! This is an example program showing logging with different levels, filenames and mpi

  call MPI_Init(ierr)

  log(crit,*) "help we had an error"
  log_root(err,*) "this is a warning"
  log_root(warn,*) "this is a warning with a filename"
  log_root(info,*) "here, have some info with a filename"
  log_root(debug,*) "and this is a debug message"
  log_root(debug,*) "and this is a debug message 2"
  log_root(crit,*) "help we had an error"
  log_root(err,*) "this is a warning"

  ! Enable date output
  call log_set_default_output_date(.true.)
  log_root(err,*) "Error from thread 0 with line-info and mpi id and date"

  call MPI_Finalize(ierr)

end program
