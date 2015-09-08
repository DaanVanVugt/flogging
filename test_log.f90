#include "logging.h"
program test_log
  use logging

  implicit none
  integer :: mpi_id, other_mpi_id

  ! This is an example program showing logging with different levels, filenames and mpi

  logn(error) "help we had an error"
  logf(error) "help we had an error, with filename"
  logn(warn) "this is a warning"
  logf(warn) "this is a warning with a filename"
  logn(info) "here, have some info"
  logf(info) "here, have some info with a filename"
  logn(debug) "and this is a debug message"
  logf(debug) "and this is a debug message with a filename"
  logn(trace) "also you can use trace-messages"
  logf(trace) "And print the current line"

  ! The next part is mpi support
  mpi_id = 0
  other_mpi_id = 3
  logm(error, mpi_id) "error from thread 0"
  logm(warn, other_mpi_id) "Warning from thread 3"
  if (mpi_id .eq. 0) then
    logn(info) "Global program info"
  endif
  if (other_mpi_id .eq. 0) then
    logn(info) "Only gets shown once"
  endif

  ! All the bells and whistles
  if (mpi_id .eq. 0) then
    logmf(error, mpi_id) "Error from thread 0 with line-info and mpi id"
  endif

  ! Enable date output
  call set_default_output_date(.true.)
  if (mpi_id .eq. 0) then
    logmf(error, mpi_id) "Error from thread 0 with line-info and mpi id and date"
  endif
end program
