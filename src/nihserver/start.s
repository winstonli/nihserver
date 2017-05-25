%include "nihserver/assert/assert.i"
%include "nihserver/data/string.i"
%include "nihserver/linux/fd.i"
%include "nihserver/linux/syscall.i"
%include "nihserver/server/nihserver.i"

global _start

section .data

usage:
    dq `usage: nihserver [port] [web_directory]\n`
usage_end:

invalid_port:
    dq `Invalid port: `
invalid_port_end:

hello:
    dq helloend - hellostring, hellostring
hellostring:
    db `Hello world!\n`
helloend:

path:
    dq `/home/winston\0`

section .bss

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
; struct nihserver
%define srv [rbp - 40]
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
    mov rdi, fd_stdout
    mov rsi, invalid_port
    mov rdx, invalid_port_end - invalid_port
    call fd_write
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
    call string_to_int64
    mov rdi, fd_stdout
    mov rsi, hellostring
    mov rdx, helloend - hellostring
    call fd_write
    lea rdi, srv
    mov rsi, 8000
    mov rdx, path
    mov rcx, 3
    call nihserver_init
    lea rdi, srv
    call nihserver_start
    mov rbx, 0
    cmp rax, 0
    sete bl
    mov rdi, rbx
    mov rsi, 0
    call assert
    lea rdi, srv
    call nihserver_deinit
    mov rdi, 1
.done:
    call syscall_exit
    add rsp, frame_size
    pop rbp
    ret
