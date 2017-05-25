%define STRING_S

%include "nihserver/data/string.i"

%include "nihserver/assert/assert.i"

section .text

global string_append_int32

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
string_append_int32:
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
    mov rbx, rend
    mov [rbx], dl
    inc rbx
    mov rend, rbx
    cmp rax, 0
    jg .do_while_i_g_0
    mov al, negative
    cmp al, 1
    jne .endif_negative
    mov rbx, rend
    mov byte [rbx], '-'
    inc rbx
    mov rend, rbx
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
