%define MEM_S

%include "nihserver/data/mem.i"

%include "nihserver/linux/log.i"
%include "nihserver/linux/syscall.i"

section .data

mmap_failed:
    db `Failed to munmap\n`

section .text

global mem_copy

global mem_cmp

global mem_alloc_chunk

global mem_free_chunk

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


mem_alloc_chunk:
    mov rdi, 0
    mov rsi, MEM_CHUNK_SIZE
    mov rdx, PROT_READ | PROT_WRITE
    mov rcx, MAP_ANONYMOUS | MAP_GROWSDOWN | MAP_PRIVATE
    mov r8, -1
    mov r9, 0
    call syscall_mmap
    ret


mem_free_chunk:
    mov rsi, MEM_CHUNK_SIZE
    call syscall_munmap

    cmp eax, 0
    je .done

    mov rdi, mmap_failed
    mov esi, eax
    neg esi
    call log_perror

.done:
    ret
