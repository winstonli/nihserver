%define MEM_S

%include "nihserver/data/mem.i"

section .text

global mem_copy

mem_copy:
.while_n_g_0:
    cmp rdx, 0
    jng .done
    mov al, [rsi]
    mov [rdi], al
    inc rdi
    inc rsi
    dec rdx
    jmp .while_n_g_0
.done:
    ret
