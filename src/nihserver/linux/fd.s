%define FD_S

%include "nihserver/linux/fd.i"

%include "nihserver/data/string.i"
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

global fd_init_with_fd

global fd_init_with_socket

global fd_deinit

global fd_accept

global fd_bind

global fd_fsync

global fd_listen

global fd_read

global fd_setsockopt

global fd_shutdown

global fd_write

global fd_write_all

global fd_print

global fd_putb

global fd_putc

global fd_puti32

global fd_putp

global fd_puts

global fd_to_string

fd_init:
    push rbp
    mov rsi, INVALID_FD
    call fd_init_with_fd
    pop rbp
    ret

fd_init_with_fd:
    push rbp
    call fd_set_fd
    pop rbp
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
    mov esi, fd
    call fd_set_fd
    mov eax, result
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

%define frame_size 48
; struct fd *
%define self [rbp - 8]
; struct sockaddr *
%define upeer_sockaddr [rbp - 16]
; int32_t *
%define upeer_addrlen [rbp - 24]
; struct fd *
%define upeer_fd [rbp - 32]
; int32_t
%define fd [rbp - 36]
; int32_t
%define result [rbp - 40]
fd_accept:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov upeer_sockaddr, rsi
    mov upeer_addrlen, rdx
    mov upeer_fd, rcx
    call fd_get_fd
    mov fd, eax
    mov edi, eax
    mov rsi, upeer_sockaddr
    mov rdx, upeer_addrlen
    call syscall_accept
    cmp eax, 0
    jge .else_accept_l_0
    mov result, eax
    mov dword fd, INVALID_FD
    jmp .endif_accept_l_0
.else_accept_l_0:
    mov fd, eax
    mov dword result, 0
.endif_accept_l_0:
    mov rdi, upeer_fd
    mov esi, fd
    call fd_init_with_fd
    mov eax, result
    add rsp, frame_size
    pop rbp
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

fd_fsync:
    push rbp
    call fd_get_fd
    mov edi, eax
    call syscall_fsync
    pop rbp
    ret

%define frame_size 16
; struct fd *
%define self [rbp - 8]
; int32_t
%define backlog [rbp - 12]
fd_listen:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov backlog, rsi
    call fd_get_fd
    mov rdi, rax
    mov rsi, backlog
    call syscall_listen
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 32
; struct fd *
%define self [rbp - 8]
; int8_t *
%define buf [rbp - 16]
; uint64_t
%define count [rbp - 24]
fd_read:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov buf, rsi
    mov count, rdx
    call fd_get_fd
    mov edi, eax
    mov rsi, buf
    mov rdx, count
    call syscall_read
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 32
; struct fd *
%define self [rbp - 8]
; int32_t
%define level [rbp - 12]
; int32_t
%define optname [rbp - 16]
; int8_t *
%define optval [rbp - 24]
; int32_t
%define optlen [rbp - 28]
fd_setsockopt:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov level, esi
    mov optname, edx
    mov optval, rcx
    mov optlen, r8d
    call fd_get_fd
    mov rdi, rax
    mov esi, level
    mov edx, optname
    mov rcx, optval
    mov r8d, optlen
    call syscall_setsockopt
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 16
; struct fd *
%define self [rbp - 8]
; int32_t
%define how [rbp - 12]
fd_shutdown:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    call fd_get_fd
    mov edi, eax
    mov esi, how
    call syscall_shutdown
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
; const void *
%define buf [rbp - 16]
; uint64_t
%define count [rbp - 24]
; uint64_t
%define written [rbp - 32]
fd_write_all:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov buf, rsi
    mov count, rdx
    mov qword written, 0
.while_written_le_count:
    mov rax, written
    mov rdx, count
    cmp rax, rdx
    jnl .endwhile_written_l_count
    sub rdx, rax
    mov rdi, self
    mov rsi, buf
    call fd_write
    cmp rax, 0
    jnl .endif_write_l_0
    mov rax, 0
    jmp .done
.endif_write_l_0:
    add written, rax
    add buf, rax
    jmp .while_written_le_count
.endwhile_written_l_count:
    mov rax, 1
.done:
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

%define frame_size 48
; struct fd *
%define self [rbp - 8]
; int32_t
%define i [rbp - 12]
; int8_t[11]
%define buf [rbp - 28]
; int8_t *
%define s [rbp - 36]
fd_puti32:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov i, esi
    lea rax, buf
    mov s, rax
    mov rdi, s
    mov rsi, 11
    mov edx, i
    call string_from_int32
    add rax, s
    mov byte [rax], 0
    mov rdi, self
    mov rsi, s
    call fd_puts
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

%define frame_size 16
; int8_t *
%define s [rbp - 8]
; uint64_t
%define size [rbp - 16]
fd_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov s, rsi
    mov size, rdx
    call fd_get_fd
    mov edx, eax
    mov rdi, s
    mov rsi, size
    call string_from_int32
    add rsp, frame_size
    pop rbp
    ret
