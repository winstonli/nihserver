%define FD_S

%include "nihserver/linux/fd.i"

%include "nihserver/linux/syscall.i"

section .data

global fd_stdin

global fd_stdout

global fd_stderr

fd_stdin:
    dd 0
fd_stdout:
    dd 1
fd_stderr:
    dd 2

%define INVALID_FD -1

hex_table:
dq "0123456789abcdef"

hex_prefix:
dq `0x\0`

failed_to_close_fd:
dq `failed to close fd\n\0`

section .text

global fd_init

global fd_init_with_socket

global fd_deinit

global fd_bind

global fd_write

global fd_print

global fd_putb

global fd_putc

global fd_putp

global fd_puts

fd_init:
    mov rsi, INVALID_FD
    call fd_set_fd
    ret

%define frame_size 48
; struct fd *
%define self [rbp - 8]
; int32_t
%define family [rbp - 16]
; int32_t
%define type [rbp - 24]
; int32_t
%define protocol [rbp - 32]
; int32_t
%define result [rbp - 40]
; int32_t
%define fd [rbp - 48]
fd_init_with_socket:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov family, rsi
    mov type, rdx
    mov protocol, rcx
    mov rdi, family
    mov rsi, type
    mov rdx, protocol
    call syscall_socket
    cmp rax, 0
    jge .else_fd_lt_0
    mov result, rax
    mov qword fd, INVALID_FD
    jmp .endif_fd_lt_0
.else_fd_lt_0:
    mov qword result, 0
    mov fd, rax
.endif_fd_lt_0:
    mov rdi, self
    mov rsi, fd
    call fd_set_fd
    mov rax, result
    add rsp, frame_size
    pop rbp
    ret

fd_deinit:
    call fd_get_fd
    cmp rax, -1
    je .done
    mov rdi, rax
    call syscall_close
    cmp rax, 0
    jge .done
    mov rdi, fd_stderr
    mov rsi, failed_to_close_fd
    call fd_puts
.done:
    ret

; int32_t fd_get_fd(struct fd *self);
fd_get_fd:
    movsxd rax, [rdi + OFFSETOF_fd_fd]
    ret

; void fd_set_fd(struct fd *self, int32_t fd);
fd_set_fd:
    mov [rdi + OFFSETOF_fd_fd], esi
    ret

%define frame_size 32
; struct fd *
%define self [rbp - 8]
; const struct sockaddr *
%define addr [rbp - 16]
; uint64_t
%define addrlen [rbp - 24]
fd_bind:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov addr, rsi
    mov addrlen, rdx
    call fd_get_fd
    mov rdi, rax
    mov rsi, addr
    mov rdx, addrlen
    call syscall_bind
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 32
; struct fd *
%define self [rbp - 8]
; const void *
%define buf [rbp - 16]
; uint64_t
%define count [rbp - 24]
fd_write:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov buf, rsi
    mov count, rdx
    call fd_get_fd
    mov rdi, rax
    mov rsi, buf
    mov rdx, count
    call syscall_write
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 32
; struct fd *
%define self [rbp - 8]
; uint8_t
%define b [rbp - 16]
; int32_t
%define r [rbp - 24]
fd_putb:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov b, rsi
    mov al, b
    and rax, 0xf0
    shr rax, 4
    mov rsi, hex_table
    add rsi, rax
    mov rsi, [rsi]
    mov rdi, self
    call fd_putc
    cmp rax, 1
    jne .done
    mov r, rax
    mov al, b
    and rax, 0xf
    mov rsi, hex_table
    add rsi, rax
    mov rsi, [rsi]
    mov rdi, self
    call fd_putc
    add rax, r
.done:
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 16
; struct fd *
%define self [rbp - 8]
; int8_t
%define c [rbp - 16]
fd_putc:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov c, rsi
    mov rdi, self
    lea rsi, c
    mov rdx, 1
    call fd_write
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 32
; struct fd *self
%define self [rbp - 8]
; const void *
%define p [rbp - 16]
; int32_t
%define shift [rbp - 24]
fd_putp:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov p, rsi
    mov rdi, self
    mov rsi, hex_prefix
    call fd_puts
    mov qword shift, 56
.while_shift_ge_0:
    mov rcx, shift
    cmp rcx, 0
    jl .endwhile_shift_ge_0
    mov rsi, p
    shr rsi, cl
    and rsi, 0xff
    mov rdi, self
    call fd_putb
    mov rcx, shift
    sub rcx, 8
    mov shift, rcx
    jmp .while_shift_ge_0
.endwhile_shift_ge_0:
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 16
; struct fd *
%define self [rbp - 8]
; const char *
%define s [rbp - 16]
fd_puts:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov s, rsi
.while:
    mov rax, s
    mov al, [rax]
    cmp al, 0
    je .endwhile
    mov rdi, self
    mov rsi, rax
    call fd_putc
    mov rax, s
    inc rax
    mov s, rax
    jmp .while
.endwhile:
    add rsp, frame_size
    pop rbp
    ret
