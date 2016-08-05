!**************************************************************
! This module contains a logging system intended for use in MPI
! codes, with facilities for colored output, log level filters,
! code location and date and time annotation.
!
! This software is governed by the MIT license, found in the
! file LICENSE.
!**************************************************************
#include "flogging.h"
module flogging
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
  integer, public, parameter :: NUM_LOG_LEVELS = 6 !< 1 through 6 (fatal through trace)
  integer, public, parameter :: LOG_FATAL = LOG_LEVEL_FATAL_DEF !< = 1, Runtime error causing termination
  integer, public, parameter :: LOG_ERROR = LOG_LEVEL_ERROR_DEF !< = 2, Runtime error
  integer, public, parameter :: LOG_WARN  = LOG_LEVEL_WARN_DEF !< = 3, Warning, but we can continue
  integer, public, parameter :: LOG_INFO  = LOG_LEVEL_INFO_DEF !< = 4, Interesting events
  integer, public, parameter :: LOG_DEBUG = LOG_LEVEL_DEBUG_DEF !< = 5, Detailed debug output, disable by compiling your program with -DDISABLE_LOG_DEBUG
  integer, public, parameter :: LOG_TRACE = LOG_LEVEL_TRACE_DEF   !< = 6, Extremely detailed output, compile your program with -DENABLE_LOG_TRACE to enable

  integer, public, save :: logu = stderr !< By default, log to stderr
  integer, public, save :: minimum_log_level = LOG_INFO !< Note that more critical means a lower number


  public :: log_set_output_hostname
  public :: log_set_output_severity
  public :: log_set_output_date
  public :: log_set_output_time
  public :: log_set_output_fileline
  public :: log_set_skip_terminal_check
  public :: log_set_disable_colors
  public :: log_disable_cli_arguments

  public :: logp, logl




  private
  ! Default settings for hostname and severity output
  logical, save :: output_hostname     = .false.
  logical, save :: output_severity     = .true.
  logical, save :: output_date         = .false.
  logical, save :: output_time         = .false.
  logical, save :: output_fileline     = .true.
  logical, save :: skip_terminal_check = .false.
  logical, save :: disable_colors      = .false.
  logical, save :: cla_checked         = .false. 

  ! These are the color codes corresponding to the loglevels above
  character(len=*), dimension(NUM_LOG_LEVELS), parameter :: color_codes = &
      ["31", "31", "33", "32", "34", "30"]
  ! These are the styles corresponding to the loglevels above
  character(len=*), dimension(NUM_LOG_LEVELS), parameter :: style_codes = &
      [bold, reset, reset, reset, reset, reset]

  ! Colors for other output
  character(len=*), parameter :: level_color = "20"

contains
  !**** Settings functions (public)
  !> Set the default for hostname output
  subroutine log_set_output_hostname(bool)
    logical, intent(in) :: bool
    output_hostname = bool
  end subroutine log_set_output_hostname

  !> Set the default for severity output
  subroutine log_set_output_severity(bool)
    logical, intent(in) :: bool
    output_severity = bool
  end subroutine log_set_output_severity

  !> Set the default for date output
  subroutine log_set_output_date(bool)
    logical, intent(in) :: bool
    output_date = bool
  end subroutine log_set_output_date

  !> Set time-only date format
  subroutine log_set_output_time(bool)
    logical, intent(in) :: bool
    output_time = bool
  end subroutine log_set_output_time

  !> Set the default for file/line output
  subroutine log_set_output_fileline(bool)
    logical, intent(in) :: bool
    output_fileline = bool
  end subroutine log_set_output_fileline

  !> Whether or not to skip the terminal check
  subroutine log_set_skip_terminal_check(bool)
    logical, intent(in) :: bool
    skip_terminal_check = bool
  end subroutine log_set_skip_terminal_check

  !> Disable colors altogether
  subroutine log_set_disable_colors(bool)
    logical, intent(in) :: bool
    disable_colors = bool
  end subroutine log_set_disable_colors

  !> Disable reading arguments from the commandline
  subroutine log_disable_cli_arguments()
    cla_checked = .true.
  end subroutine





  !**** Logging functions (public)
  !> Output this log statement or not
  function logp(level, only_n)
#ifdef USE_MPI
    use mpi
#endif

    integer, intent(in)           :: level     !< The log level of the current message
    integer, intent(in), optional :: only_n    !< Show only if the current mpi rank equals only_n
    logical                       :: logp      !< Output: true if this log message can be printed

#ifdef USE_MPI
    integer :: rank, ierr
#endif

    ! Check command-line arguments if that has not been done yet
    if (.not. cla_checked) call log_check_cli_arguments()

    if (level .le. minimum_log_level) then
      logp = .true.
    else
      logp = .false.
    endif
#ifdef USE_MPI
    if (logp .and. present(only_n)) then
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      if (rank .ne. only_n) logp = .false.
    endif
#endif
  end function logp

  !> Write a log lead containing level and optional info
  !> The name is shortened to allow for longer log messages without needing continuations
  function logl(level, filename, linenum)
    ! Input parameters
    integer                    :: level    !< The log level
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
    if (level .lt. 1) level = 1
    if (level .gt. minimum_log_level .or. level .gt. NUM_LOG_LEVELS) return

    ! only show colors if we are outputting to a terminal
    if (skip_terminal_check) then
      show_colors = .not. disable_colors
    else
      show_colors = isatty(stdout) .and. .not. disable_colors
    endif
    ! This works in ifort and gfortran (log_unit is stdout here because log_lead is an internal string)

    ! Initialize log_tmp
    log_tmp = ""
    fn_len = 0

    ! Reset the colors if needed
    if (show_colors) call stput(log_tmp(i), reset) ! Do not increment i to add it before the next space

    ! Write date and time if wanted
    if (output_date .or. output_time) then
      log_tmp(i) = trim(log_tmp(i)) // log_datetime()
      i = i + 1
    endif

    ! Write hostname if requested
    if (output_hostname) then
      log_tmp(i) = trim(log_tmp(i)) // log_hostname()
      i = i + 1
    endif

#ifdef USE_MPI
    ! Write mpi id
    log_tmp(i) = trim(log_tmp(i)) // log_mpi_id()
    i = i + 1
#endif

    if (present(filename) .and. output_fileline) then
      log_tmp(i) = trim(log_tmp(i)) // trim(filename)
      if (present(linenum)) then
        ! Left-justify the line number and cap it to 4 characters
        write(linenum_lj, '(i4)') linenum
        log_tmp(i) = trim(log_tmp(i)) // ":" // adjustl(linenum_lj)
      endif
      ! How many extra spaces are needed to fill out to multiple of n characters
      fn_len = fn_len + len_trim(log_tmp(i))
      i = i+1
    endif

    ! Output severity level
    if (output_severity) then
      fn_len = fn_len + len_trim(log_severity(level, .false.))
      log_tmp(i) = trim(log_tmp(i)) // spaces(mod(7-fn_len,8)+8) // log_severity(level, show_colors)
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




  !*** Utility functions (private)
  !> Return the hostname in a 50 character string
  function log_hostname()
    character(len=50) log_hostname
    call hostnm(log_hostname)
  end function log_hostname

  !> Return n spaces
  function spaces(n)
    integer, intent(in) :: n !< Maximum is 30
    character(len=n)    :: spaces
    spaces = "                              "
  end function spaces

  !> Return the severity level with colors etc in a 50 char string
  function log_severity(level, show_colors)
    integer, intent(in) :: level
    logical, intent(in) :: show_colors
    character(len=50) log_severity

    log_severity = ""
    if (show_colors) call stput(log_severity, level_color)
    if (level .eq. LOG_FATAL) then
      if (show_colors) then
        call stput(log_severity, bold)
        call stput(log_severity, color_codes(level)) ! error has the same color, for reading convenience
      endif
      log_severity = trim(log_severity) // "FATAL"
    elseif (level .eq. LOG_ERROR) then
      if (show_colors) call stput(log_severity, bold)
      log_severity = trim(log_severity) // "ERROR"
    elseif (level .eq. LOG_WARN) then
      log_severity = trim(log_severity) // "WARN"
    elseif (level .eq. LOG_INFO) then
      log_severity = trim(log_severity) // "INFO"
    elseif (level .eq. LOG_DEBUG) then
      log_severity = trim(log_severity) // "DEBUG"
    elseif (level .eq. LOG_TRACE) then
      log_severity = trim(log_severity) // "TRACE"
    endif
    if (show_colors) call stput(log_severity, reset)
  end function log_severity

#ifdef USE_MPI
  !> Return the mpi id of the current process
  function log_mpi_id()
    use mpi
    character(50) :: log_mpi_id    !< The mpi id part of a log
    character(6)  :: mpi_id_lj     !< MPI id in string
    character(4)  :: id_fmt        !< The forhmat to print mpi_id_lj in
    integer :: rank, n_cpu, ierr

    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, n_cpu, ierr)
    if (n_cpu .eq. 1) then
      log_mpi_id = ""
    else
      write(id_fmt, '(A,i1,A)') "(i", ceiling(log10(real(n_cpu))), ")"
      write(mpi_id_lj,id_fmt) rank
      write(log_mpi_id, '("#",a)') trim(adjustl(mpi_id_lj))
    endif
  end function log_mpi_id
#endif

  !> Return the current date, formatted nicely
  function log_datetime()
    character(50) :: log_datetime !< Output the date here

    character(8)  :: date
    character(10) :: time
    character(5)  :: zone

    call date_and_time(date, time, zone)
    if (output_date .and. output_time) then
      write(log_datetime, '(a,"/",a,"/",a," ",a,":",a,":",a," ")') date(1:4), date(5:6), date(7:8), &
            time(1:2), time(3:4), time(5:6)
    endif
    if (output_time) then
      write(log_datetime, '(a,":",a,":",a," ")') time(1:2), time(3:4), time(5:6)
    endif
    if (output_date) then
      write(log_datetime, '(a,"/",a,"/",a," ")') date(1:4), date(5:6), date(7:8)
    endif
  end function log_datetime

  !> Check the command-line arguments to set the default logging level
  !> and color settings.
  subroutine log_check_cli_arguments()
    integer :: i,length,status
    character(len=32) :: arg
    
    ! Loop over all command-line arguments to look for -v
    do i=1,command_argument_count()
      call get_command_argument(i,arg,length,status)
      if (status .eq. 0) then
        select case (trim(arg))
          case ("--verbose")
            minimum_log_level = min(NUM_LOG_LEVELS,minimum_log_level+1)
          case ("-v")
            minimum_log_level = min(NUM_LOG_LEVELS,minimum_log_level+1)
          case ("-vv")
            minimum_log_level = min(NUM_LOG_LEVELS,minimum_log_level+2)
          case ("-vvv")
            minimum_log_level = min(NUM_LOG_LEVELS,minimum_log_level+3)
          case ("-vvvv")
            minimum_log_level = min(NUM_LOG_LEVELS,minimum_log_level+4)
          case ("-vvvvv")
            minimum_log_level = min(NUM_LOG_LEVELS,minimum_log_level+5)
          case ("-q")
            minimum_log_level = max(1,minimum_log_level-1)
          case ("-qq")
            minimum_log_level = max(1,minimum_log_level-2)
          case ("-qqq")
            minimum_log_level = max(1,minimum_log_level-3)
          case ("-qqqq")
            minimum_log_level = max(1,minimum_log_level-4)
          case ("-qqqqq")
            minimum_log_level = max(1,minimum_log_level-5)
          case ("--quiet")
            minimum_log_level = max(1,minimum_log_level-1)
          case ("--log-output-hostname")
            output_hostname = .true.
          case ("--log-force-colors")
            skip_terminal_check = .true.
          case ("--log-no-colors")
            disable_colors = .true.
          case ("--log-output-date")
            output_date = .true.
          case ("--log-output-time")
            output_time = .true.
        end select
      endif
    enddo
    cla_checked = .true.
  end subroutine log_check_cli_arguments
end module flogging
