module logging
  ! Outputs (fortran 2003 required)
  use, intrinsic :: iso_fortran_env, only: stdin=>input_unit, &
                                           stdout=>output_unit, &
                                           stderr=>error_unit
  implicit none
  ! Color setup
  character(len=*), parameter :: start = achar(27)
  ! List of logging colors
  character(len=*), parameter :: reset = "[0m", bold = "[1m"
  character(len=*), dimension(5), parameter :: color_codes = &
      ["[31m", "[32m", "[33m", "[34m", "[35m"]
  character(len=*), parameter :: level_color = "[20m"

  ! Enable or disable date output
  logical, parameter :: output_date = .true.
  integer, parameter :: LOG_ERROR = 1, LOG_WARN = 2, LOG_INFO = 3, LOG_DEBUG = 4, LOG_TRACE = 5
  character(len=*), parameter :: date_color = "[32m"

  logical, parameter :: output_hostname = .true.
  logical, parameter :: output_severity = .true.
contains
  subroutine log(level, msg, filename, linenum)
    implicit none
    ! Input parameters
    integer                    :: level
    character(len=*)           :: msg
    character(len=*), optional :: filename
    integer, optional          :: linenum

    ! Internal parameters
    character(8)  :: date
    character(10) :: time
    character(5)  :: zone
    character(4)  :: linenum_lj ! left-justified line number
    character(len=100) :: hostname
    integer :: status_value = 0


    ! Write date and time if needed
    if (output_date) then
      call date_and_time(date, time, zone)
      ! Set up color for date
      write(stderr, '(a,a)', advance="no") start, date_color
      write(stderr, '(a,"/",a,"/",a," ",a,":",a,":",a," ")', advance="no") date(1:4), date(5:6), date(7:8), &
          time(1:2), time(3:4), time(5:6)
      ! Reset color
      write(stderr, '(a,a)', advance="no") start, reset
    endif

    ! Write hostname if needed and found (does not work yet)
    if (output_hostname) then
      call get_environment_variable("HOSTNAME",hostname, status=status_value)
      if (status_value .eq. 0) then ! If it fits in 100 characters and exists
        write(stderr, '(a," ")', advance="no") trim(hostname)
      endif
    endif

    ! Output severity level
    if (output_severity) then
      write(stderr, '(a,a)', advance="no") start, level_color
      if (level .eq. LOG_ERROR) then
        write(*, "(a)", advance="no") "ERROR "
      elseif (level .eq. LOG_WARN) then
        write(*, "(a)", advance="no") "WARN  "
      elseif (level .eq. LOG_INFO) then
        write(*, "(a)", advance="no") "INFO  "
      elseif (level .eq. LOG_DEBUG) then
        write(*, "(a)", advance="no") "DEBUG "
      elseif (level .eq. LOG_TRACE) then
        write(*, "(a)", advance="no") "TRACE "
      endif
      write(stderr, "(a,a)", advance="no") start, reset
    endif

    if (present(filename)) then
      write(stderr, "(a)", advance="no") filename
    endif

    if (present(linenum)) then
      ! Left-justify the line number and cap it to 4 characters
      write(linenum_lj, '(i4)') linenum
      write(stderr, "(':',a,' ')", advance="no") adjustl(linenum_lj)
    endif

    ! Set color based on severity level
    write(stderr, "(a,a)", advance="no") start, color_codes(level)

    ! Write the log message
    write(stderr, "(a)", advance="no") msg

    ! Finish the line and unset the color
    write(stderr, "(a,a)") start, reset
  end subroutine log
end module logging
