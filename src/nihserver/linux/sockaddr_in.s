%define SOCKADDR_IN_S

%include "nihserver/linux/sockaddr_in.i"

section .text

global sockaddr_in_init

global sockaddr_in_deinit

sockaddr_in_init:
    mov eax, esi
    mov [rdi + OFFSETOF_sockaddr_in_sin_family], ax
    mov [rdi + OFFSETOF_sockaddr_in_sin_port], dh
    mov [rdi + OFFSETOF_sockaddr_in_sin_port + 1], dl
    mov [rdi + OFFSETOF_sockaddr_in_sin_addr], ecx
    mov qword [rdi + OFFSETOF_sockaddr_in_sin_zero], 0
    ret

sockaddr_in_deinit:
    ret
