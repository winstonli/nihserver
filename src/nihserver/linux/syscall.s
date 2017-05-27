%define SYSCALL_S

%include "nihserver/linux/syscall.i"

section .data

global syscall_open

global syscall_accept

global syscall_bind

global syscall_close

global syscall_stat

global syscall_exit

global syscall_fstat

global syscall_fsync

global syscall_listen

global syscall_read

global syscall_sendfile

global syscall_sendto

global syscall_setsockopt

global syscall_shutdown

global syscall_socket

global syscall_write


syscall_open:
    mov rax, 2
    syscall
    ret


syscall_accept:
    mov rax, 43
    syscall
    ret


syscall_bind:
    mov rax, 49
    syscall
    ret


syscall_close:
    mov rax, 3
    syscall
    ret


syscall_stat:
    mov rax, 4
    syscall
    ret


syscall_exit:
    mov rax, 60
    syscall
    ret


syscall_fstat:
    mov rax, 5
    syscall
    ret


syscall_fsync:
    mov rax, 74
    syscall
    ret


syscall_listen:
    mov rax, 50
    syscall
    ret


syscall_read:
    mov rax, 0
    syscall
    ret


syscall_sendfile:
    mov rax, 40
    mov r10, rcx
    syscall
    ret


syscall_sendto:
    mov rax, 44
    mov r10d, ecx
    syscall
    ret


syscall_setsockopt:
    mov rax, 54
    mov r10, rcx
    syscall
    ret


syscall_shutdown:
    mov rax, 48
    syscall
    ret


syscall_socket:
    mov rax, 41
    syscall
    ret


syscall_write:
    mov rax, 1
    syscall
    ret
