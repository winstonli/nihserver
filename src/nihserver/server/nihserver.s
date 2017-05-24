%define NIHSERVER_S

%include "nihserver/linux/fd.i"
%include "nihserver/linux/sockaddr_in.i"
%include "nihserver/linux/syscall.i"
%include "nihserver/server/nihserver.i"

%define INVALID_FD -1

section .text

global nihserver_init

global nihserver_deinit

global nihserver_start

%define frame_size 32
; struct nihserver *
%define self [rbp - 8]
; uint16_t
%define port [rbp - 16]
; const char *
%define filepath [rbp - 24]
nihserver_init:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov port, rsi
    mov filepath, rdx
    call nihserver_get_fd
    mov rdi, rax
    call fd_init
    mov rdi, self
    mov rsi, port
    call nihserver_set_port
    mov rdi, self
    mov rsi, filepath
    call nihserver_set_filepath
    add rsp, frame_size
    pop rbp
    ret

nihserver_deinit:
    push rbp
    call nihserver_get_fd
    mov rdi, rax
    call fd_deinit
    pop rbp
    ret

%define frame_size 48
; struct nihserver *
%define self [rbp - 8]
; struct fd *
%define fd [rbp - 16]
; uint16_t port
%define port [rbp - 18]
; struct sockaddr_in
%define addr [rbp - 40]
; uint64_t addrlen
%define addrlen [rbp - 48]
nihserver_start:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    call nihserver_get_fd
    mov fd, rax
    mov rdi, fd
    call fd_deinit
    mov rdi, fd
    mov rsi, AF_INET
    mov rdx, SOCK_STREAM
    mov rcx, 0
    call fd_init_with_socket
    cmp rax, 0
    jge .endif_result_l_0
    jmp .done
.endif_result_l_0:
    mov rdi, self
    call nihserver_get_port
    mov port, ax
    lea rdi, addr
    mov esi, AF_INET
    mov dx, port
    mov ecx, 0
    call sockaddr_in_init
    mov qword addrlen, SIZEOF_sockaddr_in
    mov rdi, fd
    lea rsi, addr
    mov rdx, addrlen
    call fd_bind
    cmp rax, 0
    jge .endif_bind_l_0
    jmp .done
.endif_bind_l_0:

.done:
    add rsp, frame_size
    pop rbp
    ret

; struct fd *nihserver_get_fd(struct nihserver *self);
nihserver_get_fd:
    lea rax, [rdi + OFFSETOF_nihserver_fd]
    ret

; uint16_t nihserver_get_port(const struct nihserver *self);
nihserver_get_port:
    movsx eax, word [rdi + OFFSETOF_nihserver_port]
    ret

; void nihserver_set_port(struct nihserver *self, uint16_t port);
nihserver_set_port:
    mov eax, esi
    mov [rdi + OFFSETOF_nihserver_port], ax
    ret

; void nihserver_set_filepath(struct nihserver *self, const char *filepath);
nihserver_set_filepath:
    mov [rdi + OFFSETOF_nihserver_filepath], rsi
    ret
