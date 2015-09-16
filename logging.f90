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
  integer :: log_unit = stderr

  ! Default settings for hostname and severity output
  logical :: default_output_hostname = .true.
  logical :: default_output_severity = .true.
  logical :: default_output_date = .false.
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
  character(len=*), parameter :: date_color = "32"



contains
  !> This routine redirects logging output to another unit (for output to file)
  subroutine set_log_unit(unit)
    implicit none
    integer, intent(in) :: unit
    log_unit = unit
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
  subroutine set_default_log_level(level)
    implicit none
    integer, intent(in) :: level
    default_log_level = level
  end subroutine set_default_log_level

  !> Output this log statement or not
  function print_log(level, only_root)
#ifdef USE_MPI
    use mpi
#endif
    implicit none

    integer, intent(in)           :: level     !< The log level of the current message
    logical, intent(in), optional :: only_root !< Whether to show this message regardless of originating thread
    logical                       :: print_log !< Output: true if this log message can be printed

    integer :: rank, ierr

    if (level .le. default_log_level) print_log = .true.
#ifdef USE_MPI
    if (print_log .and. present(only_root) .and. only_root) then
      call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
      if (rank .ne. 0) print_log = .false.
    endif
#endif
  end function print_log

  !> Write a log lead containing level and optional info
  function log_lead(level, filename, linenum)
#ifdef USE_MPI
    use mpi
#endif
    implicit none
    ! Input parameters
    integer                    :: level    !< The log level, between 1 and 5
    character(len=*), optional :: filename !< An optional filename to add to the log lead
    integer, optional          :: linenum  !< With line number
    character(len=200)         :: log_lead
    character(len=200)         :: log_tmp

    ! Internal parameters
    character(8)  :: date
    character(10) :: time
    character(5)  :: zone
    character(6)  :: mpi_id_lj     ! Left-justified mpi id
    character(4)  :: linenum_lj ! left-justified line number
    character(len=100) :: hostname
    logical :: show_colors = .false.
    logical :: t
    integer :: rank, ierr
    t = .true.

    ! Set level to 1 if it is too low
    if (level .lt. 1) level = 1
    if (level .gt. default_log_level .or. level .gt. 5) return ! Skip if level too low

    ! only show colors if we are outputting to a terminal
    show_colors = isatty(stdout) ! This works in ifort and gfortran (log_unit here because log_lead is an internal string)
    ! XXX does not check log_unit since this fails for stderr
    ! Reset the colors if needed
    if (show_colors) call stput(log_lead, reset)

    ! Write date and time if wanted
    if (default_output_date) then
      if (show_colors) call stput(log_lead, date_color)
      call date_and_time(date, time, zone)
      write(log_tmp, '(a,"/",a,"/",a," ",a,":",a,":",a," ")') date(1:4), date(5:6), date(7:8), &
          time(1:2), time(3:4), time(5:6)
      log_lead = log_lead // trim(log_tmp)
      if (show_colors) call stput(log_lead, reset)
    endif

    ! Write hostname if requested
    if (default_output_hostname) then
      call hostnm(hostname)
      write(log_tmp, '(a)') trim(hostname)
      log_lead = log_lead // trim(log_tmp)
    endif

    ! Write mpi id
#ifdef USE_MPI
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    write(mpi_id_lj,'(i6)') rank
    write(log_tmp, '("#",a," ")') trim(adjustl(mpi_id_lj))
    log_lead = log_lead // trim(log_tmp)
#endif

    ! Output severity level
    if (default_output_severity) then
      if (show_colors) call stput(log_lead, level_color)
      if (level .eq. LOG_CRITICAL) then
        if (show_colors) then
          call stput(log_lead, bold)
          call stput(log_lead, color_codes(level)) ! error has the same color, for reading convenience
        endif
        write(log_tmp, "(a)") "CRIT "
        log_lead = log_lead // trim(log_tmp)
      elseif (level .eq. LOG_ERROR) then
        if (show_colors) call stput(log_lead, bold)
        write(log_tmp, "(a)") "ERROR"
        log_lead = log_lead // trim(log_tmp)
      elseif (level .eq. LOG_WARNING) then
        write(log_tmp, "(a)") "WARN "
        log_lead = log_lead // trim(log_tmp)
      elseif (level .eq. LOG_INFO) then
        write(log_tmp, "(a)") "INFO "
        log_lead = log_lead // trim(log_tmp)
      elseif (level .eq. LOG_DEBUG) then
        write(log_tmp, "(a)") "DEBUG"
        log_lead = log_lead // trim(log_tmp)
      endif
      if (show_colors) call stput(log_lead, reset)
    endif

    if (present(filename)) then
      write(log_tmp, "(' ',a)") filename
      log_lead = log_lead // trim(log_tmp)
    endif

    if (present(linenum)) then
      ! Left-justify the line number and cap it to 4 characters
      write(linenum_lj, '(i4)') linenum
      write(log_tmp, "(':',a)") adjustl(linenum_lj)
      log_lead = log_lead // trim(log_tmp)
    endif

    ! Set color based on severity level
    if (show_colors) then
      ! Set bold for errors (must go first, resets the color code otherwise)
      call stput(log_lead, style_codes(level))
      call stput(log_lead, color_codes(level))
    endif
  end function log_lead
end module logging
