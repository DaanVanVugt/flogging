module logging
  use :: vt100 ! For color output

#ifdef f2003
  use, intrinsic :: iso_fortran_env, only: stdin=>input_unit, stdout=>output_unit, stderr=>error_unit
#else
#define stdin  5
#define stdout 6
#define stderr 0
#endif

  implicit none

  ! Log levels
  integer, parameter :: LOG_CRITICAL = 1, crit = 1,&
                        LOG_ERROR    = 2, err  = 2,&
                        LOG_WARNING  = 3, warn = 3,&
                        LOG_INFO     = 4, info = 4,&
                        LOG_DEBUG    = 5, debug= 5

  ! By default, log to stderr
  integer :: logu = stderr

  ! Default settings for hostname and severity output
  logical :: default_output_hostname = .true.
  logical :: default_output_severity = .true.
  logical :: default_output_date     = .false.
  logical :: default_output_fileline = .true.
#ifdef DEBUG
  integer :: default_log_level = 5
#else
  integer :: default_log_level = 4
#endif

  ! These are the color codes corresponding to the loglevels above
  character(len=*), dimension(5), parameter :: color_codes = &
      ["31", "31", "33", "32", "34"]
  ! These are the styles corresponding to the loglevels above
  character(len=*), dimension(5), parameter :: style_codes = &
      [bold, reset, reset, reset, reset]

  ! Colors for other output
  character(len=*), parameter :: level_color = "20"

contains
  !**** Settings functions
  !> This routine redirects logging output to another unit (for output to file)
  subroutine set_log_unit(unit)
    implicit none
    integer, intent(in) :: unit
    logu = unit
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

  !> Set the default for file/line output
  subroutine set_default_output_fileline(bool)
    implicit none
    logical, intent(in) :: bool
    default_output_fileline = bool
  end subroutine set_default_output_fileline

  !> Set the minimum log level to display
  subroutine set_default_log_level(level)
    implicit none
    integer, intent(in) :: level
    default_log_level = level
  end subroutine set_default_log_level




  !**** Logging functions
  !> Output this log statement or not
  function logp(level, only_n)
#ifdef USE_MPI
    use mpi
#endif
    implicit none

    integer, intent(in)           :: level     !< The log level of the current message
    integer, intent(in), optional :: only_n    !< Whether to show this message regardless of originating thread
    logical                       :: logp      !< Output: true if this log message can be printed

    integer :: rank, ierr

    if (level .le. default_log_level) logp = .true.
#ifdef USE_MPI
    if (logp .and. present(only_n)) then
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      if (rank .ne. only_n) logp = .false.
    endif
#endif
  end function logp

  !> Write a log lead containing level and optional info
  !! The name is shortened to allow for longer log messages without needing continuations
  function logl(level, filename, linenum)
    implicit none
    ! Input parameters
    integer                    :: level    !< The log level, between 1 and 5
    character(len=*), optional :: filename !< An optional filename to add to the log lead
    integer, optional          :: linenum  !< With line number
    character(len=300)         :: logl     !< The output log leader

    ! Internal parameters
    character(len=50), dimension(6) :: log_tmp !< The different parts of the log lead
    integer                         :: fn_len  !< Add extra spaces after part i
    integer       :: i,j !< The counter for the different parts
    character(4)  :: linenum_lj ! left-justified line number

    logical :: show_colors = .false.
    i = 1

    ! Set level to 1 if it is too low, skip if too high
    ! TODO check verbose cli flag
    if (level .lt. 1) level = 1
    if (level .gt. default_log_level .or. level .gt. 5) return

    ! only show colors if we are outputting to a terminal
    show_colors = isatty(stdout) ! This works in ifort and gfortran (log_unit here because log_lead is an internal string)
    show_colors = .true.
    ! XXX does not check log_unit since this fails for stderr
    ! TODO check color override CLI flag

    ! Initialize log_tmp
    log_tmp = ""
    fn_len = 0

    ! Reset the colors if needed
    if (show_colors) call stput(log_tmp(i), reset) ! Do not increment i to add it before the next space

    ! Write date and time if wanted
    if (default_output_date) then
      log_tmp(i) = trim(log_tmp(i)) // log_date()
      i = i + 1
    endif

    ! Write hostname if requested
    if (default_output_hostname) then
      log_tmp(i) = trim(log_tmp(i)) // log_hostname()
      i = i + 1
    endif

#ifdef USE_MPI
    ! Write mpi id
    log_tmp(i) = trim(log_tmp(i)) // log_mpi_id()
    i = i + 1
#endif

    if (present(filename) .and. default_output_fileline) then
      log_tmp(i) = trim(log_tmp(i)) // trim(filename)
      if (present(linenum)) then
        ! Left-justify the line number and cap it to 4 characters
        write(linenum_lj, '(i4)') linenum
        log_tmp(i) = trim(log_tmp(i)) // ":" // adjustl(linenum_lj)
      endif
      ! How many extra spaces are needed to fill out to multiple of n characters
      fn_len = len_trim(log_tmp(i))
      i = i+1
    endif

    ! Output severity level
    if (default_output_severity) then
      fn_len = fn_len + len_trim(log_severity(level, .false.))
      log_tmp(i) = trim(log_tmp(i)) // spaces(mod(9-fn_len,10)+10) // log_severity(level, show_colors)
      i = i + 1
    endif

    ! Set color based on severity level
    if (show_colors) then
      ! Set bold for errors (must go first, resets the color code otherwise)
      call stput(log_tmp(i), style_codes(level))
      call stput(log_tmp(i), color_codes(level))
    endif

    ! Concatenate trim(log_tmp(i)) with spaces in between
    logl = log_tmp(1)
    do j=2,i
      logl = trim(logl) // " " // trim(log_tmp(j))
    enddo
  end function logl




  !*** Utility functions
  !> Return the hostname in a 50 character string
  function log_hostname()
    implicit none
    character(len=50) log_hostname
    call hostnm(log_hostname)
  end function log_hostname

  function spaces(n)
    implicit none
    integer, intent(in) :: n !< Maximum is 30
    character(len=n)    :: spaces
    spaces = "                              "
  end function spaces

  !> Return the severity level with colors etc in a 50 char string
  function log_severity(level, show_colors)
    implicit none
    integer, intent(in) :: level
    logical, intent(in) :: show_colors
    character(len=50) log_severity

    log_severity = ""
    if (show_colors) call stput(log_severity, level_color)
    if (level .eq. LOG_CRITICAL) then
      if (show_colors) then
        call stput(log_severity, bold)
        call stput(log_severity, color_codes(level)) ! error has the same color, for reading convenience
      endif
      log_severity = trim(log_severity) // "CRITICAL"
    elseif (level .eq. LOG_ERROR) then
      if (show_colors) call stput(log_severity, bold)
      log_severity = trim(log_severity) // "ERROR"
    elseif (level .eq. LOG_WARNING) then
      log_severity = trim(log_severity) // "WARN"
    elseif (level .eq. LOG_INFO) then
      log_severity = trim(log_severity) // "INFO"
    elseif (level .eq. LOG_DEBUG) then
      log_severity = trim(log_severity) // "DEBUG"
    endif
    if (show_colors) call stput(log_severity, reset)
  end function log_severity

#ifdef USE_MPI
  !> Return the mpi id of the current process
  function log_mpi_id()
    use mpi
    implicit none
    character(50) :: log_mpi_id    !< The mpi id part of a log
    character(6)  :: mpi_id_lj     ! Left-justified mpi id
    integer :: rank, ierr

    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    write(mpi_id_lj,'(i4)') rank
    write(log_mpi_id, '("#",a)') trim(adjustl(mpi_id_lj))
  end function log_mpi_id
#endif

  !> Return the current date, formatted nicely
  function log_date()
    implicit none
    character(50) :: log_date !< Output the date here

    character(8)  :: date
    character(10) :: time
    character(5)  :: zone

    call date_and_time(date, time, zone)
    write(log_date, '(a,"/",a,"/",a," ",a,":",a,":",a," ")') date(1:4), date(5:6), date(7:8), &
        time(1:2), time(3:4), time(5:6)
  end function log_date
end module logging
