%define LOG_S

%include "nihserver/linux/fd.i"
%include "nihserver/linux/log.i"
%include "nihserver/thread/lock.i"

section .data

stderr_lock:
    dd 0

stdout_lock:
    dd 0

section .text

global log_err

log_err:
    push rdi

    mov rdi, stderr_lock
    call lock_acquire

    mov rdi, fd_stderr
    pop rsi
    call fd_puts

    mov rdi, stderr_lock
    call lock_release

    ret
