# Flogging
This logging system aims to be simple to use, similar to existing write statements and therefore easy to implement in existing codes,
while providing some convenient extra features not present in fortran by default.

Usage is very simple:
```fortran
use flogging
```

To load the logging module and its utility functions.
To use the preprovided macros, include the header file and turn on the preprocessor by compiling with -cpp
```C
#include "flogging.h"
```
This macro defines the following functions:
```fortran
log(level, format)
log_fatal(format)
log_error(format)
log_warn(format)
log_info(format)
log_debug(format)
log_trace(format)

log_root(level, format)
log_root_fatal(format)
log_root_error(format)
log_root_warn(format)
log_root_info(format)
log_root_debug(format)
log_root_trace(format)
```
Where `format` is usually `*`, but can be adjusted to suit your needs. Remember to include a single `A` specifier for the log lead.

The functions print a log message only if the level is greater than or equal to the current minimum loglevel.
The second set of functions function includes a check to print a log message only from the root MPI process, if compiled
with `USE_MPI`. If not compiled with `USE_MPI`, it works the same as the log function.

If you do not want to use the preprocessor macros, you can log like this.
```fortran
if (logp(LEVEL)) then
  write(logu,FORMAT) trim(logl(LEVEL))//" ", "this is a log message"
endif
```
Note that it is not possible to use the filename and linenumber features then.

# Installation
You can compile `flogging.f90` and `vt100.f90` into a library `flogging.so` with `make`.
To compile with MPI support use 
```bash
make USE_MPI=1
```
Then, place `libflogging.so` into your `LD_LIBRARY_PATH` and put `flogging.h` into your include path.


# Examples
```fortran
log(err,*) "this is an error"
log(warn,*) "this is a warning"
log(info,*) "here, have some info"
log(debug,*) "and this is a debug message"
```
outputs
```
 localhost test.f90:9  ERROR this is an error
 localhost test.f90:10  WARN this is a warning
 localhost test.f90:11  INFO here, have some info
```
(The leading space is a consequence of using the fortran * format specifier)

## Interface
The module `flogging` defines some subroutines you can use to alter it's behaviour:
```fortran
public :: log_set_output_hostname
public :: log_set_output_severity
public :: log_set_output_date
public :: log_set_time_only
public :: log_set_output_fileline
public :: log_set_skip_terminal_check
public :: log_set_disable_colors
public :: log_disable_cli_arguments
```

## Command-line flags
The logging module allows the following command-line flags, checked at the time of the first log output.
```
  -v, --verbose                 Increase the logging verbosity
  -q, --quiet                   Decrease the logging verbosity
  --log-output-hostname         Output the hostname in the log lead
  --log-force-colors            Force colors, even when outputting to a file
  --log-no-colors               Disable colors (overrides --log-force-colors)
  --log-output-date             Output the date in the log lead
  --log-output-time             Output the time in the log lead
```

### Argument parsing
By default, flogging parses the command-line arguments above on the first invocation of `log()`.
If you want to use your own argument parsing you can disable this behaviour by calling `log_disable_cli_arguments` before any output is logged.

## Output to a file
Logging is to stderr by default. Another output unit can be selected by setting
```fortran
  logu = some_unit
```
This will probably not work well with MPI.

## Internals
The module defines a function defining whether or not to print this log message,
```fortran
  logp(level)
```
where level is one of `LOG_FATAL`, `LOG_ERROR`, `LOG_WARN`, `LOG_INFO`, `LOG_DEBUG` or `LOG_TRACE`.
The logp function can also be used with MPI support, using an optional integer parameter `only_n` to return true
only if the level is sufficient and the MPI rank of the current thread is equal to `only_n`.
This can be used to print messages only from the root thread, to prevent log messages from being printed N times as shown below.
```fortran
  logp(level,0)
```
