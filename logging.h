! If debug is set, enable the debug and trace functions, otherwise do not compile them
#ifdef DEBUG
#define debug call wll(4); write(lu,*)
#define debugf call wll(4, __FILE__, __LINE__); write(lu,*)
#define trace call wll(5, __FILE__, __LINE__); write(lu,*)
#else
#define debug !
#define debugf !
#define trace !
#endif

! These short definitions are for brevity, allowing longer lines after the write statement
#define info call wll(3); write(lu,*) 
#define infof call wll(3, __FILE__, __LINE__); write(lu,*) 
#define warn call wll(2); write(lu,*)
#define warnf call wll(2, __FILE__, __LINE__); write(lu,*)
#define error call wll(1); write(lu,*)
#define errorf call wll(1, __FILE__, __LINE__); write(lu,*)

! More flexibility can be obtained by writing the log statement yourself:
! call wll(LOG_LEVEL); write(lu,"FORMAT") variables
