#include "logging.h"
program test_log
  use logging

  implicit none

  error "help we had an error"
  errorf "help we had an error, with filename"
  warn "this is a warning"
  warnf "this is a warning with a filename"
  info "here, have some info"
  infof "here, have some info with a filename"
  debug "and this is a debug message"
  debugf "and this is a debug message with a filename"
  trace "also you can use trace-messages which print the current file and line"
end program
