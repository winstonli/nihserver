%define SOCKADDR_IN_S

%include "nihserver/linux/sockaddr_in.i"

%include "nihserver/data/math.i"
%include "nihserver/data/mem.i"
%include "nihserver/data/string.i"

section .data

section .text

global sockaddr_in_init

global sockaddr_in_deinit

global sockaddr_in_to_string

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

%define frame_size 96
; const struct sockaddr_in *
%define self [rbp - 8]
; int8_t *
%define s [rbp - 16]
; uint64_t
%define size [rbp - 24]
; int8_t[22]
%define buf [rbp - 48]
; int8_t *
%define buf_ptr [rbp - 56]
; const int8_t *
%define buf_start [rbp - 64]
; const int8_t *
%define buf_end [rbp - 72]
; uint32_t addr
%define addr [rbp - 80]
; int8_t
%define shift [rbp - 88]
; uint64_t
%define n [rbp - 96]
sockaddr_in_to_string:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov s, rsi
    mov size, rdx
    lea rax, buf
    mov buf_ptr, rax
    mov buf_start, rax
    add rax, 22
    mov buf_end, rax
    mov eax, [rdi + OFFSETOF_sockaddr_in_sin_addr]
    mov addr, eax
    mov byte shift, 0
.while_shift_le_24:
    mov ecx, 0
    mov cl, shift
    cmp cl, 24
    jnle .endwhile_shift_le_24
    mov ebx, addr
    shr ebx, cl
    and ebx, 0xff
    mov rdi, buf_ptr
    mov rsi, buf_end
    sub rsi, rdi
    mov edx, ebx
    call string_from_int32
    add buf_ptr, rax
    mov cl, shift
    cmp cl, 24
    je .endif_shift_ne_24
    mov rax, buf_ptr
    mov byte [rax], '.'
    inc qword buf_ptr
.endif_shift_ne_24:
    add byte shift, 8
    jmp .while_shift_le_24
.endwhile_shift_le_24:
    mov rax, buf_ptr
    mov byte [rax], ':'
    inc qword buf_ptr
    mov rdi, self
    call sockaddr_in_get_port
    mov edx, eax
    mov rdi, buf_ptr
    mov rsi, buf_end
    sub rsi, rdi
    call string_from_int32
    add rax, buf_ptr
    mov byte [rax], `\0`
    inc rax
    mov buf_ptr, rax
    mov rdi, buf_ptr
    sub rdi, buf_start
    mov rsi, size
    call min_u64
    mov n, rax
    mov rdx, rax
    mov rdi, s
    mov rsi, buf_start
    call mem_copy
    mov rax, n
    add rsp, frame_size
    pop rbp
    ret

sockaddr_in_get_port:
    mov eax, 0
    mov ah, [rdi + OFFSETOF_sockaddr_in_sin_port]
    mov al, [rdi + OFFSETOF_sockaddr_in_sin_port + 1]
    ret
