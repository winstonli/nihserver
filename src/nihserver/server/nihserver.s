%define NIHSERVER_S

%include "nihserver/server/nihserver.i"

%include "nihserver/assert/assert.i"
%include "nihserver/linux/fd.i"
%include "nihserver/linux/sockaddr_in.i"
%include "nihserver/linux/syscall.i"

%define INVALID_FD -1

section .data

hello:
    dq `hello\n`
helloend:

section .bss

peer_addr:
    db 24

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

%define frame_size 80
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
; struct sockaddr_in
%define upeer_sockaddr [rbp - 64]
; int32_t
%define upeer_addrlen [rbp - 68]
; struct fd
%define upeer_fd [rbp - 72]
; int32_t
%define optval [rbp - 76]
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
    mov dword optval, 1
    mov rdi, fd
    mov rsi, SOL_SOCKET
    mov rdx, SO_REUSEADDR
    lea rcx, optval
    mov r8, 4
    call fd_setsockopt
    cmp rax, 0
    jge .endif_setsockopt_l_0
    jmp .done
.endif_setsockopt_l_0:
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
    mov rdi, fd
    mov rsi, 256
    call fd_listen
    cmp rax, 0
    jge .endif_listen_l_0
    jmp .done
.endif_listen_l_0:
    mov dword upeer_addrlen, SIZEOF_sockaddr_in
    mov rdi, fd
    lea rsi, upeer_sockaddr
    lea rdx, upeer_addrlen
    lea rcx, upeer_fd
    call fd_accept
    mov ebx, 0
    cmp eax, 0
    sete bl
    mov rdi, rbx
    mov rsi, 0
    call assert
    lea rdi, upeer_sockaddr
    mov rsi, peer_addr
    mov rdx, 24
    call sockaddr_in_to_string
    mov rdi, fd_stdout
    mov rsi, peer_addr
    call fd_puts
    lea rdi, upeer_fd
    mov rsi, hello
    mov rdx, helloend - hello
    call fd_write
    mov ebx, 0
    cmp eax, 0
    setge bl
    mov rdi, rbx
    mov rsi, 0
    call assert
    lea rdi, upeer_fd
    call fd_deinit
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
