%define LOCK_S

%include "nihserver/linux/syscall.i"
%include "nihserver/thread/lock.i"

section .text

global lock_acquire

global lock_release


lock_acquire:
.zero:
    ; Uncontended 0 -> 1 case
    mov eax, 0
    mov esi, 1
    lock cmpxchg [rdi], esi
    jz .done

.not_zero:

    cmp eax, 1
    jne .two

; .one: but don't jump here
    ; Newly contended 1 -> 2 case
    mov esi, 2
    lock cmpxchg [rdi], esi
    jz .two

; .not_one: but don't jump here
    cmp eax, 0
    je .zero

.two:
    ; Try to sleep on 2 -> 2
    push rdi

    mov esi, FUTEX_WAIT
    mov edx, 2
    mov rcx, 0
    mov r8, 0
    mov r9, 0
    call syscall_futex

    pop rdi

; .not_two: but don't jump here
    jmp .zero

.done:
    ret


lock_release:
    mov eax, 1
    mov esi, 0
    lock cmpxchg [rdi], esi
    jz .done

.not_one:
    mov dword [rdi], 0
    mov esi, FUTEX_WAKE
    mov edx, 1
    mov rcx, 0
    mov r8, 0
    mov r9, 0
    call syscall_futex

.done:
    ret
