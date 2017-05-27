%define STRING_S

%include "nihserver/data/string.i"

%include "nihserver/assert/assert.i"

section .text

global string_from_int32

global string_from_uint64

global string_to_int64

global string_length


%define frame_size 64
; int8_t *s
%define s [rbp - 8]
; int8_t *start
%define start [rbp - 16]
; int8_t *end
%define end [rbp - 24]
; int64_t
%define i [rbp - 32]
; boolean
%define negative [rbp - 36]
; int8_t[11]
%define rev [rbp - 48]
; int8_t *
%define rstart [rbp - 56]
; int8_t *
%define rend [rbp - 64]
string_from_int32:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    mov s, rdi
    mov start, rdi
    add rsi, rdi
    mov end, rsi
    mov i, rdx
    lea rax, rev
    mov rstart, rax
    mov rend, rax

    cmp edx, 0
    jge .endif_i_lt_0

    mov dword negative, 1
    neg edx
    mov i, rdx

.endif_i_lt_0:
    mov rax, i

.do_while_i_g_0:
    mov rdx, 0
    mov rcx, 10
    div rcx
    add dl, '0'
    mov r8, rend
    mov [r8], dl
    inc r8
    mov rend, r8
    cmp rax, 0
    jg .do_while_i_g_0

    cmp dword negative, 1
    jne .endif_negative

    mov r8, rend
    mov byte [r8], '-'
    inc r8
    mov rend, r8

.endif_negative:
    mov r8, rstart
    mov r9, rend
    dec r9
    mov r10, start
    mov r11, end

.while_rend_ge_rstart_and_start_lt_end:
    cmp r9, r8
    jl .endwhile_rend_ge_rstart_and_start_lt_end

    cmp r10, r11
    jge .endwhile_rend_ge_rstart_and_start_lt_end

    mov al, [r9]
    mov [r10], al
    dec r9
    inc r10
    jmp .while_rend_ge_rstart_and_start_lt_end

.endwhile_rend_ge_rstart_and_start_lt_end:
    mov rax, r10
    sub rax, s

    add rsp, frame_size
    pop rbp
    ret


%define frame_size 80
; int8_t *s
%define s [rbp - 8]
; int8_t *start
%define start [rbp - 16]
; int8_t *end
%define end [rbp - 24]
; uint64_t
%define u [rbp - 32]
; int8_t[21]
%define rev [rbp - 56]
; int8_t *
%define rstart [rbp - 64]
; int8_t *
%define rend [rbp - 72]
string_from_uint64:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    mov s, rdi
    mov start, rdi
    add rsi, rdi
    mov end, rsi
    mov u, rdx
    lea rax, rev
    mov rstart, rax
    mov rend, rax

    mov rax, rdx

.do_while_u_g_0:
    mov rdx, 0
    mov rcx, 10
    div rcx
    add dl, '0'
    mov r8, rend
    mov [r8], dl
    inc r8
    mov rend, r8
    cmp rax, 0
    jg .do_while_u_g_0

    mov r8, rstart
    mov r9, rend
    dec r9
    mov r10, start
    mov r11, end

.while_rend_ge_rstart_and_start_lt_end:
    cmp r9, r8
    jl .endwhile_rend_ge_rstart_and_start_lt_end

    cmp r10, r11
    jge .endwhile_rend_ge_rstart_and_start_lt_end

    mov al, [r9]
    mov [r10], al
    dec r9
    inc r10
    jmp .while_rend_ge_rstart_and_start_lt_end

.endwhile_rend_ge_rstart_and_start_lt_end:
    mov rax, r10
    sub rax, s

    add rsp, frame_size
    pop rbp
    ret


%define frame_size 32
; int8_t *
%define s [rbp - 8]
; uint64_t
%define size [rbp - 16]
; int64_t *
%define o [rbp - 24]
string_to_int64:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    mov s, rdi
    mov size, rsi
    mov o, rdx
    call string_num_len

    cmp rax, 0
    jne .endif_len_e_0

    jmp .done

.endif_len_e_0:
    mov rdi, s
    mov rsi, s
    add rsi, rax
    dec rsi
    call string_to_int64_

    mov r8, o
    mov [r8], rax
    mov eax, 1

.done:
    add rsp, frame_size
    pop rbp
    ret


%define start rdi
%define end rsi
%define value rax
; int64_t string_to_int64_(int8_t *start, int8_t *end);
string_to_int64_:
    mov value, 0

    cmp byte [rdi], '-'
    jne .endif_start0_e_minus

    inc start
    mov r8, end
    sub r8, start
    mov r8, [.njump_table + 8 * r8]
    jmp r8

.c18n:
    mov rcx, 0
    mov cl, [end - 18]
    sub cl, '0'
    mov rdx, 1000000000000000000
    imul rcx, rdx
    sub value, rcx

.c17n:
    mov rcx, 0
    mov cl, [end - 17]
    sub cl, '0'
    mov rdx, 100000000000000000
    imul rcx, rdx
    sub value, rcx

.c16n:
    mov rcx, 0
    mov cl, [end - 16]
    sub cl, '0'
    mov rdx, 10000000000000000
    imul rcx, rdx
    sub value, rcx

.c15n:
    mov rcx, 0
    mov cl, [end - 15]
    sub cl, '0'
    mov rdx, 1000000000000000
    imul rcx, rdx
    sub value, rcx

.c14n:
    mov rcx, 0
    mov cl, [end - 14]
    sub cl, '0'
    mov rdx, 100000000000000
    imul rcx, rdx
    sub value, rcx

.c13n:
    mov rcx, 0
    mov cl, [end - 13]
    sub cl, '0'
    mov rdx, 10000000000000
    imul rcx, rdx
    sub value, rcx

.c12n:
    mov rcx, 0
    mov cl, [end - 12]
    sub cl, '0'
    mov rdx, 1000000000000
    imul rcx, rdx
    sub value, rcx

.c11n:
    mov rcx, 0
    mov cl, [end - 11]
    sub cl, '0'
    mov rdx, 100000000000
    imul rcx, rdx
    sub value, rcx

.c10n:
    mov rcx, 0
    mov cl, [end - 10]
    sub cl, '0'
    mov rdx, 10000000000
    imul rcx, rdx
    sub value, rcx

.c9n:
    mov rcx, 0
    mov cl, [end - 9]
    sub cl, '0'
    imul rcx, 1000000000
    sub value, rcx

.c8n:
    mov rcx, 0
    mov cl, [end - 8]
    sub cl, '0'
    imul rcx, 100000000
    sub value, rcx

.c7n:
    mov rcx, 0
    mov cl, [end - 7]
    sub cl, '0'
    imul rcx, 10000000
    sub value, rcx

.c6n:
    mov rcx, 0
    mov cl, [end - 6]
    sub cl, '0'
    imul rcx, 1000000
    sub value, rcx

.c5n:
    mov rcx, 0
    mov cl, [end - 5]
    sub cl, '0'
    imul rcx, 100000
    sub value, rcx

.c4n:
    mov rcx, 0
    mov cl, [end - 4]
    sub cl, '0'
    imul rcx, 10000
    sub value, rcx

.c3n:
    mov rcx, 0
    mov cl, [end - 3]
    sub cl, '0'
    imul rcx, 1000
    sub value, rcx

.c2n:
    mov rcx, 0
    mov cl, [end - 2]
    sub cl, '0'
    imul rcx, 100
    sub value, rcx

.c1n:
    mov rcx, 0
    mov cl, [end - 1]
    sub cl, '0'
    imul rcx, 10
    sub value, rcx

.c0n:
    mov rcx, 0
    mov cl, [end]
    sub cl, '0'
    sub value, rcx
    ret

.njump_table:
    dq .c0n, .c1n, .c2n, .c3n, .c4n, .c5n, .c6n, .c7n, .c8n, .c9n
    dq .c10n, .c11n, .c12n, .c13n, .c14n, .c15n, .c16n, .c17n, .c18n

.endif_start0_e_minus:
    mov r8, end
    sub r8, start
    mov r8, [.jump_table + 8 * r8]
    jmp r8

.c18:
    mov rcx, 0
    mov cl, [end - 18]
    sub cl, '0'
    mov rdx, 1000000000000000000
    imul rcx, rdx
    add value, rcx

.c17:
    mov rcx, 0
    mov cl, [end - 17]
    sub cl, '0'
    mov rdx, 100000000000000000
    imul rcx, rdx
    add value, rcx

.c16:
    mov rcx, 0
    mov cl, [end - 16]
    sub cl, '0'
    mov rdx, 10000000000000000
    imul rcx, rdx
    add value, rcx

.c15:
    mov rcx, 0
    mov cl, [end - 15]
    sub cl, '0'
    mov rdx, 1000000000000000
    imul rcx, rdx
    add value, rcx

.c14:
    mov rcx, 0
    mov cl, [end - 14]
    sub cl, '0'
    mov rdx, 100000000000000
    imul rcx, rdx
    add value, rcx

.c13:
    mov rcx, 0
    mov cl, [end - 13]
    sub cl, '0'
    mov rdx, 10000000000000
    imul rcx, rdx
    add value, rcx

.c12:
    mov rcx, 0
    mov cl, [end - 12]
    sub cl, '0'
    mov rdx, 1000000000000
    imul rcx, rdx
    add value, rcx

.c11:
    mov rcx, 0
    mov cl, [end - 11]
    sub cl, '0'
    mov rdx, 100000000000
    imul rcx, rdx
    add value, rcx

.c10:
    mov rcx, 0
    mov cl, [end - 10]
    sub cl, '0'
    mov rdx, 10000000000
    imul rcx, rdx
    add value, rcx

.c9:
    mov rcx, 0
    mov cl, [end - 9]
    sub cl, '0'
    imul rcx, 1000000000
    add value, rcx

.c8:
    mov rcx, 0
    mov cl, [end - 8]
    sub cl, '0'
    imul rcx, 100000000
    add value, rcx

.c7:
    mov rcx, 0
    mov cl, [end - 7]
    sub cl, '0'
    imul rcx, 10000000
    add value, rcx

.c6:
    mov rcx, 0
    mov cl, [end - 6]
    sub cl, '0'
    imul rcx, 1000000
    add value, rcx

.c5:
    mov rcx, 0
    mov cl, [end - 5]
    sub cl, '0'
    imul rcx, 100000
    add value, rcx

.c4:
    mov rcx, 0
    mov cl, [end - 4]
    sub cl, '0'
    imul rcx, 10000
    add value, rcx

.c3:
    mov rcx, 0
    mov cl, [end - 3]
    sub cl, '0'
    imul rcx, 1000
    add value, rcx

.c2:
    mov rcx, 0
    mov cl, [end - 2]
    sub cl, '0'
    imul rcx, 100
    add value, rcx

.c1:
    mov rcx, 0
    mov cl, [end - 1]
    sub cl, '0'
    imul rcx, 10
    add value, rcx

.c0:
    mov rcx, 0
    mov cl, [end]
    sub cl, '0'
    add value, rcx
    ret

.jump_table:
    dq .c0, .c1, .c2, .c3, .c4, .c5, .c6, .c7, .c8, .c9
    dq .c10, .c11, .c12, .c13, .c14, .c15, .c16, .c17, .c18


%define frame_size 32
; const char *
%define s [rbp - 8]
; const char *
%define ptr [rbp - 16]
; uint64_t
%define len [rbp - 24]
; uint64_t
%define total [rbp - 32]
; uint64_t string_num_len(const char *s, uint64_t len);
string_num_len:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    mov s, rdi
    mov ptr, rdi
    mov len, rsi
    mov qword total, 0

    mov rcx, len
    cmp rcx, 0
    je .endwhile_len_g_0
.while_len_g_0:
    mov rax, ptr
    mov dl, [rax]

    cmp qword total, 0
    jne .else_total_e_0

    call is_digit_or_minus
    jmp .endif_total_e_0

.else_total_e_0:
    call is_digit

.endif_total_e_0:
    cmp eax, 0
    je .endwhile_len_g_0

    inc qword ptr
    inc qword total
    loop .while_len_g_0

.endwhile_len_g_0:
    cmp qword total, 1
    jne .endif_total_e_1_and_first_e_minus

    mov rax, s
    mov r8, 0
    mov r8b, [rax]

    cmp r8b, '-'
    jne .endif_total_e_1_and_first_e_minus

    mov qword total, 0

.endif_total_e_1_and_first_e_minus:
    mov rax, total
    add rsp, frame_size
    pop rbp
    ret


; bool is_digit_or_minus(char c);
is_digit_or_minus:
    call is_digit

    cmp rax, 0
    je .endif_is_digit

    ret

.endif_is_digit:
    call is_minus
    ret


; bool is_digit(char c);
is_digit:
    cmp dl, '0'
    jnl .endif_l_0

    mov rax, 0
    ret

.endif_l_0:
    cmp dl, '9'
    jng .endif_g_9

    mov rax, 0
    ret

.endif_g_9:
    mov rax, 1
    ret


; bool is_minus(char c);
is_minus:
    mov eax, 0
    cmp dl, '-'
    sete al
    ret


string_length:
    mov eax, 0
    mov rsi, rdi

.while:
    scasb
    jne .while

    dec rdi
    mov rax, rdi
    sub rax, rsi
    ret
