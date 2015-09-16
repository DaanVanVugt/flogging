#define log(level,format) if (print_log(level)) write(log_unit,format) log_lead(level), 
#define log_root(level,format) if (print_log(level,.true.)) write(log_unit,format) log_lead(level), 
