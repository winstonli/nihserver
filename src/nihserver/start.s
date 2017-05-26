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

start_string:
    db `Starting server with { "port": \0`
start_string_:
    db `, "web_directory": "\0`
start_string__:
    db `" }\n\0`

hellostring:
    db `Hello world\n`
helloend:

failed_to_start:
    db `Failed to start server\n\0`

path:
    db `/home/winston\0`

section .text

%define frame_size 48
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
; struct nihserver
%define srv [rbp - 48]
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
    mov rdi, fd_stdout
    mov rsi, invalid_port
    call fd_puts
    mov rdi, fd_stdout
    mov rsi, port_str
    mov rdx, port_length
    call fd_write
    mov rdi, fd_stdout
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
    lea rdi, srv
    mov rsi, port
    mov rdx, path
    mov rcx, 3
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
