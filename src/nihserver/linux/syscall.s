%define SYSCALL_S

%include "nihserver/linux/syscall.i"

section .data

global syscall_accept

global syscall_bind

global syscall_close

global syscall_exit

global syscall_fstat

global syscall_listen

global syscall_read

global syscall_setsockopt

global syscall_socket

global syscall_write

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

syscall_exit:
    mov rax, 60
    syscall
    ret

syscall_fstat:
    mov rax, 5
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

syscall_setsockopt:
    mov rax, 54
    mov r10, rcx
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
