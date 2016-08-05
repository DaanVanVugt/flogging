/* This code is governed by the MIT license. See LICENSE for details. */

/* Log level constants */
#define LOG_LEVEL_FATAL_DEF 1
#define LOG_LEVEL_ERROR_DEF 2
#define LOG_LEVEL_WARN_DEF 3 
#define LOG_LEVEL_INFO_DEF 4 
#define LOG_LEVEL_DEBUG_DEF 5 
#define LOG_LEVEL_TRACE_DEF 6 

/* The lines below have little spacing to ease the fortran line-length requirement */
#define log_fatal(format) if(logp(LOG_LEVEL_FATAL_DEF))write(logu,format)trim(logl(LOG_LEVEL_FATAL_DEF,__FILE__,__LINE__))//" ",
#define log_error(format) if(logp(LOG_LEVEL_ERROR_DEF))write(logu,format)trim(logl(LOG_LEVEL_ERROR_DEF,__FILE__,__LINE__))//" ",
#define log_warn(format) if(logp(LOG_LEVEL_WARN_DEF))write(logu,format)trim(logl(LOG_LEVEL_WARN_DEF,__FILE__,__LINE__))//" ",
#define log_info(format) if(logp(LOG_LEVEL_INFO_DEF))write(logu,format)trim(logl(LOG_LEVEL_INFO_DEF,__FILE__,__LINE__))//" ",

#ifdef DISABLE_LOG_DEBUG
#define log_debug(format) if(.false.)write(logu,format)trim(logl(LOG_LEVEL_DEBUG_DEF,__FILE__,__LINE__))//" ",
#else
#define log_debug(format) if(logp(LOG_LEVEL_DEBUG_DEF))write(logu,format)trim(logl(LOG_LEVEL_DEBUG_DEF,__FILE__,__LINE__))//" ",
#endif

#ifdef ENABLE_LOG_TRACE
#define log_trace(format) if(logp(LOG_LEVEL_TRACE_DEF))write(logu,format)trim(logl(LOG_LEVEL_TRACE_DEF,__FILE__,__LINE__))//" ",
#else
#define log_trace(format) if(.false.)write(logu,format)trim(logl(LOG_LEVEL_TRACE_DEF,__FILE__,__LINE__))//" ",
#endif



#define log_root_fatal(format) if(logp(LOG_LEVEL_FATAL_DEF,0))write(logu,format)trim(logl(LOG_LEVEL_FATAL_DEF,__FILE__,__LINE__))//" ",
#define log_root_error(format) if(logp(LOG_LEVEL_ERROR_DEF,0))write(logu,format)trim(logl(LOG_LEVEL_ERROR_DEF,__FILE__,__LINE__))//" ",
#define log_root_warn(format) if(logp(LOG_LEVEL_WARN_DEF,0))write(logu,format)trim(logl(LOG_LEVEL_WARN_DEF,__FILE__,__LINE__))//" ",
#define log_root_info(format) if(logp(LOG_LEVEL_INFO_DEF,0))write(logu,format)trim(logl(LOG_LEVEL_INFO_DEF,__FILE__,__LINE__))//" ",

#ifdef DISABLE_LOG_DEBUG
#define log_root_debug(format) if(.false.)write(logu,format)trim(logl(LOG_LEVEL_DEBUG_DEF,__FILE__,__LINE__))//" ",
#else
#define log_root_debug(format) if(logp(LOG_LEVEL_DEBUG_DEF,0))write(logu,format)trim(logl(LOG_LEVEL_DEBUG_DEF,__FILE__,__LINE__))//" ",
#endif

#ifdef ENABLE_LOG_TRACE
#define log_root_trace(format) if(logp(LOG_LEVEL_TRACE_DEF,0))write(logu,format)trim(logl(LOG_LEVEL_TRACE_DEF,__FILE__,__LINE__))//" ",
#else
#define log_root_trace(format) if(.false.)write(logu,format)trim(logl(LOG_LEVEL_TRACE_DEF,__FILE__,__LINE__))//" ",
#endif
