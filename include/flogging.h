/* This code is governed by the MIT license. See LICENSE for details. */
/* The lines below have little spacing to ease the line-length requirement */
/* There is no conflict with the fortran intrinsic log because that only has one argument */
#define log(level,format) if(logp(level))write(logu,format)trim(logl(level,__FILE__,__LINE__))//" ",
#define log_fatal(format) if(logp(LOG_FATAL))write(logu,format)trim(logl(LOG_FATAL,__FILE__,__LINE__))//" ",
#define log_error(format) if(logp(LOG_ERROR))write(logu,format)trim(logl(LOG_ERROR,__FILE__,__LINE__))//" ",
#define log_warn(format) if(logp(LOG_WARN))write(logu,format)trim(logl(LOG_WARN,__FILE__,__LINE__))//" ",
#define log_info(format) if(logp(LOG_INFO))write(logu,format)trim(logl(LOG_INFO,__FILE__,__LINE__))//" ",
#define log_debug(format) if(logp(LOG_DEBUG))write(logu,format)trim(logl(LOG_DEBUG,__FILE__,__LINE__))//" ",
#define log_trace(format) if(logp(LOG_TRACE))write(logu,format)trim(logl(LOG_TRACE,__FILE__,__LINE__))//" ",
#define log_root(level,format) if(logp(level,0))write(logu,format)trim(logl(level,__FILE__,__LINE__))//" ",
#define log_root_fatal(format) if(logp(LOG_FATAL,0))write(logu,format)trim(logl(LOG_FATAL,__FILE__,__LINE__))//" ",
#define log_root_error(format) if(logp(LOG_ERROR,0))write(logu,format)trim(logl(LOG_ERROR,__FILE__,__LINE__))//" ",
#define log_root_warn(format) if(logp(LOG_WARN,0))write(logu,format)trim(logl(LOG_WARN,__FILE__,__LINE__))//" ",
#define log_root_info(format) if(logp(LOG_INFO,0))write(logu,format)trim(logl(LOG_INFO,__FILE__,__LINE__))//" ",
#define log_root_debug(format) if(logp(LOG_DEBUG,0))write(logu,format)trim(logl(LOG_DEBUG,__FILE__,__LINE__))//" ",
#define log_root_trace(format) if(logp(LOG_TRACE,0))write(logu,format)trim(logl(LOG_TRACE,__FILE__,__LINE__))//" ",
