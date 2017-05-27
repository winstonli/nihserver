%define LOG_S

%include "nihserver/linux/fd.i"
%include "nihserver/linux/log.i"
%include "nihserver/thread/lock.i"

section .data

stderr_lock:
    align 4
    dd 0

stdout_lock:
    align 4
    dd 0

section .text

global log_err

global log_err_n

global log_out

global log_out_n

global log_perror

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

log_err_n:
    push rdi

    mov rdi, stderr_lock
    call lock_acquire

    mov rdi, fd_stderr
    pop rsi
    call fd_write

    mov rdi, stderr_lock
    call lock_release

    ret

log_out:
    push rdi

    mov rdi, stdout_lock
    call lock_acquire

    mov rdi, fd_stdout
    pop rsi
    call fd_puts

    mov rdi, stdout_lock
    call lock_release

    ret

log_out_n:
    push rdi

    mov rdi, stdout_lock
    call lock_acquire

    mov rdi, fd_stdout
    pop rsi
    call fd_write

    mov rdi, stdout_lock
    call lock_release

    ret

log_perror:
    push rdi
    push rsi

    mov rdi, stderr_lock
    call lock_acquire

    mov rdi, fd_stderr
    pop rdx
    pop rsi
    call fd_perror

    mov rdi, stderr_lock
    call lock_release

    ret
