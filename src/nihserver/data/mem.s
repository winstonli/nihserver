%define MEM_S

%include "nihserver/data/mem.i"

section .text

global mem_copy

global mem_cmp


mem_copy:
    mov rcx, rdx
    cld
    rep movsb
    ret


mem_cmp:
    cmp rdx, 0
    ja .endif

    mov eax, 0
    ret

.endif:
    mov rcx, rdx
    cld
    repe cmpsb
    mov eax, 0
    mov al, byte [rdi - 1]
    sub al, byte [rsi - 1]
    ret
