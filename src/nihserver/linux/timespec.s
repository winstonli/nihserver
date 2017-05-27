%define TIMESPEC_S

%include "nihserver/linux/timespec.i"

section .text

global timespec_init


timespec_init:
    mov [rdi + OFFSETOF_timespec_tv_sec], rsi
    mov [rdi + OFFSETOF_timespec_tv_nsec], rdx
    ret
