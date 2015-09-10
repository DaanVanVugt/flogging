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
  integer, parameter :: ERROR = 1, WARN = 2, INFO = 3, DEBUG = 4, TRACE = 5

  ! These are the color codes corresponding to the loglevels above
  character(len=*), dimension(5), parameter :: color_codes = &
      ["31", "33", "32", "34", "35"]
  ! These are the styles corresponding to the loglevels above
  character(len=*), dimension(5), parameter :: style_codes = &
      [bold, reset, reset, reset, reset]

  ! Default settings for hostname and severity output
  logical :: default_output_hostname = .true.
  logical :: default_output_severity = .true.
  logical :: default_output_date = .false.
  ! Output to stderr by default
  integer :: lu = stderr
#ifdef DEBUG
  integer :: min_level = 3
#else
  integer :: min_level = 5
#endif

contains
  !> This routine redirects logging output to another unit (for output to file)
  subroutine set_log_unit(unit)
    implicit none
    integer, intent(in) :: unit
    lu = unit
  end subroutine set_log_unit
  !> Set the default for hostname output
  subroutine set_default_output_hostname(bool)
    implicit none
    logical, intent(in) :: bool
    default_output_hostname = bool
  end subroutine set_default_output_hostname
  !> Set the default for severity output
  subroutine set_default_output_severity(bool)
    implicit none
    logical, intent(in) :: bool
    default_output_severity = bool
  end subroutine set_default_output_severity
  !> Set the default for date output
  subroutine set_default_output_date(bool)
    implicit none
    logical, intent(in) :: bool
    default_output_date = bool
  end subroutine set_default_output_date
  !> Set the minimum log level to display
  subroutine set_min_level(level)
    implicit none
    integer, intent(in) :: level
    min_level = level
  end subroutine

  !> Write a log lead containing level and optional info
  subroutine wll(level, mpi_id, filename, linenum, output_hostname, output_severity, output_date)
    implicit none
    ! Input parameters
    integer                    :: level !< The log level, between 1 and 5
    integer, optional          :: mpi_id !< The optional mpi_id, ignored if -1
    character(len=*), optional :: filename !< An optional filename to add to the log lead
    integer, optional          :: linenum !< With line number
    logical, optional          :: output_hostname, output_severity, output_date !< Add some extra outputs

    ! Internal parameters
    character(8)  :: date
    character(10) :: time
    character(5)  :: zone
    character(6)  :: mpi_id_lj     ! Left-justified mpi id
    character(4)  :: linenum_lj ! left-justified line number
    character(len=100) :: hostname
    logical :: show_colors = .false.
    logical :: t
    t = .true.

    ! Set level to 1 if it is too low
    if (level .lt. 1) level = 1
    if (level .gt. min_level .or. level .gt. 5) return ! Skip if level too low

    ! only show colors if we are outputting to a terminal
    show_colors = isatty(lu) ! This works in ifort and gfortran
    ! Reset the colors if needed
    if (show_colors) call tput(lu, reset)

    ! Write date and time if wanted
    if (present(output_date) .and. output_date .or. default_output_date) then
      if (show_colors) call tput(lu, date_color)
      call date_and_time(date, time, zone)
      write(lu, '(a,"/",a,"/",a," ",a,":",a,":",a," ")', advance="no") date(1:4), date(5:6), date(7:8), &
          time(1:2), time(3:4), time(5:6)
      if (show_colors) call tput(lu, reset)
    endif

    ! Write hostname if requested
    if (present(output_hostname) .and. output_hostname .or. default_output_hostname) then
      call hostnm(hostname)
      write(lu, '(a)', advance="no") trim(hostname)
    endif
    ! Setup mpi id if given (-1 is ignored)
    if (present(mpi_id) .and. mpi_id .ne. -1) then
      write(mpi_id_lj,'(i6)') mpi_id
      write(lu, '("#",a)', advance="no") trim(adjustl(mpi_id_lj))
      write(lu, '(" ")', advance="no")
    else if (present(output_hostname) .and. output_hostname .or. default_output_hostname) then
      write(lu, '(" ")', advance="no")
    endif

    ! Output severity level
    if (present(output_severity) .and. output_severity .or. default_output_severity) then
      if (show_colors) call tput(lu, level_color)
      if (level .eq. ERROR) then
        if (show_colors) then
          call tput(lu, bold)
          call tput(lu, color_codes(level)) ! error has the same color, for reading convenience
        endif
        write(lu, "(a)", advance="no") "ERROR"
      elseif (level .eq. WARN) then
        if (show_colors) then
          call tput(lu, bold)
        endif
        write(lu, "(a)", advance="no") "WARN "
      elseif (level .eq. INFO) then
        write(lu, "(a)", advance="no") "INFO "
      elseif (level .eq. DEBUG) then
        write(lu, "(a)", advance="no") "DEBUG"
      elseif (level .eq. TRACE) then
        write(lu, "(a)", advance="no") "TRACE"
      endif
      if (show_colors) call tput(lu, reset)
    endif

    if (present(filename)) then
      write(stderr, "(' ',a)", advance="no") filename
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
