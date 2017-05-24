%include "nihserver/assert/assert.i"
%include "nihserver/linux/fd.i"
%include "nihserver/linux/syscall.i"
%include "nihserver/server/nihserver.i"

global _start

section .data

hello:
    dq helloend - hellostring, hellostring
hellostring:
    db `Hello world!\n`
helloend:

path:
    dq `/home/winston\0`

section .bss

section .text

%define frame_size 32
; struct nihserver
%define srv [rbp - 24]
_start:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov rdi, fd_stdout
    mov rsi, hellostring
    mov rdx, helloend - hellostring
    call fd_write
    lea rdi, srv
    mov rsi, 8000
    mov rdx, path
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
    call syscall_exit
    add rsp, frame_size
    pop rbp
    ret
