%include "nihserver/assert/assert.i"
%include "nihserver/data/string.i"
%include "nihserver/linux/fd.i"
%include "nihserver/linux/syscall.i"
%include "nihserver/server/nihserver.i"

%include "nihserver/data/mem.i"
%include "nihserver/thread/thread.i"
%include "nihserver/thread/lock.i"
%include "nihserver/linux/log.i"

global _start

section .data

usage:
    db `usage: nihserver [port] [web_directory] [num_threads]\n`
usage_end:

invalid_port:
    db `Invalid port: \0`

stat_err:
    db `Error when checking \0`

failed_to_start:
    db `Failed to start server\n\0`

web_dir_too_long:
    db `Web directory path is too long\n\0`

invalid_num_threads:
    db `Invalid number of threads: \0`

section .text


%define frame_size 216
; int32_t
%define argc [rbp + 8]
; const char *
%define port_str [rbp + 24]
; const char *
%define web_dir [rbp + 32]
; const char *
%define num_threads_str [rbp + 40]
; uint64_t
%define port_length [rbp - 8]
; int64_t
%define port [rbp - 16]
; uint64_t
%define web_dir_length [rbp - 24]
; int64_t
%define num_threads [rbp - 32]
; struct stat
%define stat [rbp - 176]
; struct nihserver
%define srv [rbp - 212]
_start:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    cmp dword argc, 4
    jnl .endif_argc_l_4

    mov rdi, fd_stderr
    mov rsi, usage
    mov rdx, usage_end - usage
    call fd_write

    jmp .done

.endif_argc_l_4:
    mov rdi, port_str
    call string_length

    mov port_length, rax

    cmp qword port_length, 5
    jng .endif_port_length_g_5

.invalid_port:
    mov rdi, fd_stderr
    mov rsi, invalid_port
    call fd_puts

    mov rdi, fd_stderr
    mov rsi, port_str
    mov rdx, port_length
    call fd_write

    mov rdi, fd_stderr
    mov esi, `\n`
    call fd_putc

    jmp .done

.endif_port_length_g_5:
    mov rdi, port_str
    mov rsi, port_length
    lea rdx, port
    call string_to_int64

    cmp rax, 0
    je .invalid_port

    cmp qword port, 0
    jle .invalid_port

    cmp qword port, 65535
    jg .invalid_port

.endif_bad_port:
    mov rdi, web_dir
    call string_length

    mov web_dir_length, rax

    cmp rax, 8192
    jnge .endif_web_dir_too_long

    mov rdi, web_dir_too_long
    call log_err

    jmp .done

.endif_web_dir_too_long:
    mov rdi, web_dir
    lea rsi, stat
    call syscall_stat

    cmp eax, 0
    jnl .endif_stat_l_0

    push rax
    mov rdi, fd_stderr
    mov rsi, stat_err
    call fd_puts
    pop rax

    mov rdi, fd_stderr
    mov rsi, web_dir
    mov edx, eax
    neg edx
    call fd_perror

    jmp .done

.endif_stat_l_0:
    mov rdi, num_threads_str
    call string_length

    push rax
    cmp rax, 10
    jge .invalid_num_threads

    mov rdi, num_threads_str
    pop rsi
    lea rdx, num_threads
    call string_to_int64

    cmp rax, 0
    je .invalid_num_threads

    cmp qword num_threads, 0
    jnle .endif_check_num_threads

.invalid_num_threads:

    mov rdi, invalid_num_threads
    call log_err

    mov rdi, num_threads_str
    call log_err

    mov rdi, fd_stderr
    mov esi, `\n`
    call fd_putc

    jmp .done

.endif_check_num_threads:
    mov rcx, rax
    lea rdi, srv
    mov rsi, port
    mov rdx, web_dir
    mov rcx, web_dir_length
    mov r8d, num_threads
    call nihserver_init

    lea rdi, srv
    call nihserver_start

    cmp eax, 0
    jnl .endif_start_l_0

    mov rdi, fd_stderr
    mov rsi, failed_to_start
    call fd_puts

.endif_start_l_0:
    lea rdi, srv
    call nihserver_deinit

.done:
    mov rdi, 1
    call syscall_exit

    add rsp, frame_size
    pop rbp
    ret
