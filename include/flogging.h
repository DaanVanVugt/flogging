/* This code is governed by the MIT license. See LICENSE for details. */
/* The lines below have little spacing to ease the fortran line-length requirements */

/* Log level constants */
#define LOG_LEVEL_FATAL_DEF 1
#define LOG_LEVEL_ERROR_DEF 2
#define LOG_LEVEL_WARN_DEF 3 
#define LOG_LEVEL_INFO_DEF 4 
#define LOG_LEVEL_DEBUG_DEF 5 
#define LOG_LEVEL_TRACE_DEF 6 

#define log_macro(level,format) if(logp(level))write(logu,format)trim(logl(level,__FILE__,__LINE__))//" ",
#define log_root(level,format) if(logp(level,0))write(logu,format)trim(logl(level,__FILE__,__LINE__))//" ",

/* First four log levels */
#define log_fatal(format) log_macro(LOG_LEVEL_FATAL_DEF,format)
#define log_error(format) log_macro(LOG_LEVEL_ERROR_DEF,format)
#define log_warn(format) log_macro(LOG_LEVEL_WARN_DEF,format)
#define log_info(format) log_macro(LOG_LEVEL_INFO_DEF,format)

#define log_fatal_root(format) log_root(LOG_LEVEL_FATAL_DEF,format)
#define log_error_root(format) log_root(LOG_LEVEL_ERROR_DEF,format)
#define log_warn_root(format) log_root(LOG_LEVEL_WARN_DEF,format)
#define log_info_root(format) log_root(LOG_LEVEL_INFO_DEF,format)

#ifdef DISABLE_LOG_DEBUG
#define log_debug(format) if(.false.)write(logu,format)
#define log_debug_root(format) if(.false.)write(logu,format)
#else
#define log_debug(format) log_macro(LOG_LEVEL_DEBUG_DEF,format)
#define log_debug_root(format) log_root(LOG_LEVEL_DEBUG_DEF,format)
#endif

#ifdef ENABLE_LOG_TRACE
#define log_trace(format) log_macro(LOG_LEVEL_TRACE_DEF,format)
#define log_trace_root(format) log_root(LOG_LEVEL_TRACE_DEF,format)
#else
#define log_trace(format) if(.false.)write(logu,format)
#define log_trace_root(format) if(.false.)write(logu,format)
#endif
