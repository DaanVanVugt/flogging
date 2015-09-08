#define logm(level, mpi_id) call wll(level, mpi_id); write(lu,*)
#define logmf(level,mpi_id) call wll(level, mpi_id, __FILE__, __LINE__); write(lu,*)
#define logn(level) call wll(level); write(lu,*)
#define logf(level) call wll(level, -1, __FILE__, __LINE__); write(lu,*)

! More flexibility can be obtained by writing the log statement yourself:
! call wll(level, mpi_id, filename, linenum, output_hostname, output_severity, output_date); write(lu,"FORMAT") variables
