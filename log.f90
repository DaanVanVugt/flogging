module logging
  ! Outputs (fortran 2003 required)
  use, intrinsic :: iso_fortran_env, only: stdin=>input_unit, &
                                           stdout=>output_unit, &
                                           stderr=>error_unit
  use :: vt100 ! For color output
  implicit none

  ! Color to show date and level info in
  character(len=*), parameter :: level_color = "20"
  character(len=*), parameter :: date_color = "32"

  ! Log levels
  integer, parameter :: LOG_ERROR = 1, LOG_WARN = 2, LOG_INFO = 3, LOG_DEBUG = 4, LOG_TRACE = 5

  ! These are the color codes corresponding to the loglevels above
  character(len=*), dimension(5), parameter :: color_codes = &
      ["31", "33", "32", "34", "35"]
  ! These are the styles corresponding to the loglevels above
  character(len=*), dimension(5), parameter :: style_codes = &
      [bold, reset, reset, reset, reset]

  logical, parameter :: output_hostname = .true.
  logical, parameter :: output_severity = .true.
#ifdef LOG_DATE
  logical, parameter :: output_date = .true.
#else
  logical, parameter :: output_date = .false.
#endif


  ! Output to:
  integer, parameter :: lu = stderr

contains
  subroutine wll(level, filename, linenum)
    implicit none
    ! Input parameters
    integer                    :: level
    character(len=*), optional :: filename
    integer, optional          :: linenum

    ! Internal parameters
    character(8)  :: date
    character(10) :: time
    character(5)  :: zone
    character(4)  :: linenum_lj ! left-justified line number
    character(len=100) :: hostname
    integer :: status_value = 0
    logical :: show_colors = .false.
    logical :: t
    t = .true.

    show_colors = isatty(lu) ! This works in ifort and gfortran
    ! Reset the colors if needed
    if (show_colors) call tput(lu, reset)

    ! Write date and time if wanted
    if (output_date) then
      if (show_colors) call tput(lu, date_color)
      call date_and_time(date, time, zone)
      write(lu, '(a,"/",a,"/",a," ",a,":",a,":",a," ")', advance="no") date(1:4), date(5:6), date(7:8), &
          time(1:2), time(3:4), time(5:6)
      if (show_colors) call tput(lu, reset)
    endif

    ! Write hostname if needed and found (does not work yet)
    if (output_hostname) then
      call hostnm(hostname)
      write(lu, '(a," ")', advance="no") trim(hostname)
    endif

    ! Output severity level
    if (output_severity) then
      if (show_colors) call tput(lu, level_color)
      if (level .eq. LOG_ERROR) then
        if (show_colors) then
          call tput(lu, bold)
          call tput(lu, color_codes(level)) ! error has the same color, for reading convenience
        endif
        write(lu, "(a)", advance="no") "ERROR"
      elseif (level .eq. LOG_WARN) then
        if (show_colors) then
          call tput(lu, bold)
        endif
        write(lu, "(a)", advance="no") "WARN "
      elseif (level .eq. LOG_INFO) then
        write(lu, "(a)", advance="no") "INFO "
      elseif (level .eq. LOG_DEBUG) then
        write(lu, "(a)", advance="no") "DEBUG"
      elseif (level .eq. LOG_TRACE) then
        write(lu, "(a)", advance="no") "TRACE"
      endif
      if (show_colors) call tput(lu, reset)
    endif

    if (present(filename)) then
      if (show_colors) call tput(lu, bold)
      write(stderr, "(' ',a)", advance="no") filename
      if (show_colors) call tput(lu, reset)
    endif

    if (present(linenum)) then
      ! Left-justify the line number and cap it to 4 characters
      write(linenum_lj, '(i4)') linenum
      write(lu, "(':',a)", advance="no") adjustl(linenum_lj)
    endif

    ! Set color based on severity level
    if (show_colors) then
      ! Set bold for errors (must go first, resets the color code otherwise)
      call tput(lu, style_codes(level))
      call tput(lu, color_codes(level))
    endif
  end subroutine wll
end module logging
