%ifndef TIMESPEC_I
%define TIMESPEC_I

; struct timespec {
;     int64_t tv_sec;
;     int 64_t tv_nsec;
; };

%define SIZEOF_timespec 16

%define OFFSETOF_timespec_tv_sec 0

%define OFFSETOF_timespec_tv_nsec 8

%ifndef TIMESPEC_S

; void timespec_init(struct timespec *self, int64_t tv_sec, int64_t tv_nsec);
extern timespec_init

%endif

%endif
