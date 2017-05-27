%define MATH_S

%include "nihserver/data/math.i"

section .text

global max_u64

global min_u64


max_u64:
    cmp rdi, rsi
    jna .endif_a_a_b

    mov rax, rdi
    jmp .done

.endif_a_a_b:
    mov rax, rsi

.done:
    ret


min_u64:
    cmp rdi, rsi
    jnb .endif_a_b_b

    mov rax, rdi
    jmp .done

.endif_a_b_b:
    mov rax, rsi

.done:
    ret
