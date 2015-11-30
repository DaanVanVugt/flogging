# Flogging
This logging system aims to be simple to use, similar to existing write statements and therefore easy to implement in existing codes,
while providing some convenient extra features not present in fortran by default.

Usage is very simple:
```
use flogging
```

To load the logging module and its utility functions.
To use the preprovided macros, include the header file and turn on the preprocessor by compiling with -cpp
``` 
#include "logging.h"
```
This macro defines two functions: `log(level, format)` and `log_root(level, format)`.
The functions print a log message only if the level is greater than or equal to the current loglevel.
The second function includes a check to print a log message only from the root MPI process, if compiled
with `USE_MPI`. If not compiled with `USE_MPI`, it works the same as the log function.

If you do not want to use the preprocessor macros, you can log like this.
```
if (logp(LEVEL)) then
  write(logu,FORMAT) trim(logl(LEVEL)), "this is a log message"
endif
```
Note that it is not possible to use the filename and linenumber features then.

## Examples
Compiling the below code without `-DDEBUG`
```
log(crit,*) "help we had a critical error"
log(err,*) "this is an error"
log(warn,*) "this is a warning"
log(info,*) "here, have some info"
log(debug,*) "and this is a debug message"
```
outputs
```
 localhost test.f90:8      CRITICAL help we had a critical error
 localhost test.f90:9         ERROR this is an error
 localhost test.f90:10         WARN this is a warning
 localhost test.f90:11         INFO here, have some info
```
(The leading space is a consequence of using the fortran * format specifier)

## Command-line flags
The logging module allows the following command-line flags, checked at the time of the first log output.
`./test -v` or `./test --verbose` increases the log level by 1. Multiple calls increase the loglevel by 1 every time,
as in `./test -v -v`. Making the output less verbose can be done by using the `-q` flag, or `-quiet`, as in
`./test -q`, `./test -q -q` or `./test --quiet`.

Checking whether the log output is a terminal can be skipped by calling
`./test --force-colors`, while `./test --no-colors` disables colors altogether.
`--no-colors` takes precedence, so specifying both on the command-line means that the output will not contain colors.

## Advanced usage
Logging is to stderr by default. Another output unit can be selected by calling
```
  log_set_unit(unit)
```

By default, the hostname of the current computer is shown in the log. This can be
enabled/disabled by calling
```
  log_set_default_output_hostname(bool)
```
Whether or not to output the severity level (default=.true.) can be set with
```
  log_set_default_output_severity(bool)
```
By default, the current date and time are not shown. This can be enabled/disabled with
```
  log_set_default_output_date(bool)
```
By default, the current filename and linenumber are shown. This can be disabled/enabled with
```
  log_set_default_output_fileline(bool)
```
The default lowest log level shown is INFO, or DEBUG if compiled with -DDEBUG. This can be
changed with
```
  log_set_default_log_level(level)
```
### Colors
By default, colors are used if stdout is connected to a terminal (the check fails with stderr on gfortran at least)
This can be disabled by calling
```
  log_set_disable_colors(bool)
```
The check for stdout being a terminal can be disabled by calling
```
  log_set_skip_terminal_check(bool)
```

## Internals
The module defines a function defining whether or not to print this log message,
```
  logp(level)
```
where level is one of `crit`, `err`, `warn`, `info` or `debug` (provided by the module, corresponding to integers 1-5),
also available as `LOG_CRITICAL`, `LOG_ERROR`, `LOG_WARNING`, `LOG_INFO` and `LOG_DEBUG` in the case of namespace collision.
The logp function can also be used with MPI support, using an optional integer parameter `only_n` to return true
only if the level is sufficient and the MPI rank of the current thread is equal to `only_n`.
This can be used to print messages only from the root thread, to prevent log messages from being printed N times as shown below.
```
  logp(level,0)
```

## Installation
Copy the files flogging.f90, vt100.f90 and logging.h into your project.
In your files, place
```
#include "logging.h"
```
and ```use flogging```.
