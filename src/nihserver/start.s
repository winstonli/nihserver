%include "nihserver/assert/assert.i"
%include "nihserver/data/string.i"
%include "nihserver/linux/fd.i"
%include "nihserver/linux/syscall.i"
%include "nihserver/server/nihserver.i"

global _start

section .data

usage:
    db `usage: nihserver [port] [web_directory]\n`
usage_end:

invalid_port:
    db `Invalid port: \0`

stat_err:
    db `Error when checking \0`

hellostring:
    db `Hello world\n`
helloend:

failed_to_start:
    db `Failed to start server\n\0`

path:
    db `/home/winston\0`

section .text

%define frame_size 192
; int32_t
%define argc [rbp + 8]
; const char *
%define port_str [rbp + 24]
; const char *
%define web_dir [rbp + 32]
; uint64_t
%define port_length [rbp - 8]
; int64_t
%define port [rbp - 16]
; struct stat
%define stat [rbp - 160]
; struct nihserver
%define srv [rbp - 192]
_start:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    cmp dword argc, 3
    jnl .endif_argc_l_3
    mov rdi, fd_stderr
    mov rsi, usage
    mov rdx, usage_end - usage
    call fd_write
    jmp .done
.endif_argc_l_3:
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
    mov rdi, web_dir
    call string_length
    mov rcx, rax
    lea rdi, srv
    mov rsi, port
    mov rdx, web_dir
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
    mov rdi, 1
.done:
    call syscall_exit
    add rsp, frame_size
    pop rbp
    ret
