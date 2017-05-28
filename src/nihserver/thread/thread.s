%define THREAD_S

%include "nihserver/data/mem.i"
%include "nihserver/linux/syscall.i"
%include "nihserver/thread/thread.i"

section .text

global thread_create


%define frame_size 0
; int32_t (*)(void *)
%define fn r12
; void *
%define arg r13
; void *stack
%define stack r14
thread_create:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size

    ; Non-scratch registers to pass data to child
    push r12
    push r13
    push r14

    mov fn, rdi
    mov arg, rsi

    call mem_alloc_chunk

    mov stack, rax
    cmp rax, 0
    jnge .done

    mov rdi, SIGCHLD | \
             CLONE_VM | CLONE_FS | CLONE_FILES | CLONE_SIGHAND | CLONE_THREAD
    mov rsi, rax
    add rsi, MEM_CHUNK_SIZE - 8
    mov rdx, 0
    mov rcx, 0
    call syscall_clone

    cmp rax, 0
    jne .done

    mov rdi, fn
    mov rsi, arg
    mov rdx, stack
    call child_start

.done:
    pop r14
    pop r13
    pop r12

    add rsp, frame_size
    pop rbp
    ret


%define frame_size 16
; int32_t (*)(void *)
%define main [rbp - 8]
; void *
%define stack [rbp - 16]
; void child_start(int32_t (*main)(void *), void *arg, void *stack);
child_start:
    mov rbp, rsp
    sub rsp, frame_size

    mov main, rdi
    mov stack, rdx

    mov rdi, rsi
    call main

    mov r10d, eax

    ; Since we free our own stack, we can no longer return from functions
    ; So these final calls must be inline

    mov rdi, stack
    mov rsi, MEM_CHUNK_SIZE
    mov rax, SYS_munmap
    syscall

.ret_addr:

    mov edi, r10d
    mov rax, SYS_exit
    syscall
