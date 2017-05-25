%define MEM_S

%include "nihserver/data/mem.i"

section .text

global mem_copy

global mem_cmp

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

mem_cmp:
.while_n_g_0:
    cmp rdx, 0
    jng .endwhile_n_g_0
    mov al, [rdi]
    cmp al, [rsi]
    jnl .endif_a_l_b
    mov eax, -1
    jmp .done
.endif_a_l_b:
    jng .endif_a_g_b
    mov eax, 1
    jmp .done
.endif_a_g_b:
    dec rdx
    jmp .while_n_g_0
.endwhile_n_g_0:
    mov eax, 0
.done:
    ret
