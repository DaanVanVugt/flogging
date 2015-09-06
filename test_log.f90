program test_log
  use logging

  implicit none

  call log(LOG_ERROR, "help we had an error")
  call log(LOG_WARN, "this is a warning")
  call log(LOG_INFO, "here, have some info")
  call log(LOG_DEBUG, "and this is a debug message", __FILE__, __LINE__)
  call log(LOG_TRACE, "also you can sprinkle trace-messages", __FILE__, __LINE__)
end program
