%ifndef LOCK_I
%define LOCK_I

; struct lock {
;     int32_t futex;
; };

%define SIZEOF_lock 4

%define OFFSETOF_futex 0

%ifndef LOCK_S

; void lock_acquire(struct lock *self);
extern lock_acquire

; void lock_release(struct lock *self);
extern lock_release

%endif

%endif
