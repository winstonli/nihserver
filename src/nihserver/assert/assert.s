%define NIHSERVER_ASSERT_ASSERT_S

%include "nihserver/assert/assert.i"

%include "nihserver/linux/fd.i"
%include "nihserver/linux/syscall.i"

section .data

assert_error:
dq `assert error\0`

assert_error_colon:
dq `: \0`

section .text

global assert


assert:
    push rbp

    call assert_true

    cmp rax, 0
    jne .endif

    mov rdi, 2
    call syscall_exit

.endif:
    pop rbp
    ret


%define frame_size 16
; const char *
%define msg [rbp - 8]
; int32_t
%define r [rbp - 16]
assert_true:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    cmp rdi, 0
    jne .else_cond_equals_0

.assert_failed:
    mov msg, rsi
    mov rdi, fd_stderr
    mov rsi, assert_error
    call fd_puts

    mov rax, msg
    cmp rax, 0
    je .endif_msg_is_not_null

    mov rdi, fd_stderr
    mov rsi, assert_error_colon
    call fd_puts

    mov rdi, fd_stderr
    mov rsi, msg
    call fd_puts

.endif_msg_is_not_null:
    mov rdi, fd_stderr
    mov rsi, `\n`
    call fd_putc

    mov dword r, 0
    jmp .endif_cond_equals_0

.else_cond_equals_0:
    mov dword r, 1

.endif_cond_equals_0:
    mov eax, r

    add rsp, frame_size
    pop rbp
    ret
