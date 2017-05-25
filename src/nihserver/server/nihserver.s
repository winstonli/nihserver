%define NIHSERVER_S

%include "nihserver/server/nihserver.i"

%include "nihserver/assert/assert.i"
%include "nihserver/data/mem.i"
%include "nihserver/data/string.i"
%include "nihserver/linux/fd.i"
%include "nihserver/linux/sockaddr_in.i"
%include "nihserver/linux/syscall.i"

%define INVALID_FD -1

section .data

hello:
    dq `hello\n`
helloend:

listen_msg:
    db "Listening on "
listen_addr:
    times 24 db 0
    align 8

accept_msg:
    db "Accepted connection from: "
peer_addr:
    times 24 db 0
    align 8

get_string:
    dq "GET "

http_1_1:
    db "HTTP/1.1 "
http_1_1_end:
    align 8

headers_pre_content_length:
    db `\r\nServer: nihserver/1.0\r\nConnection: close\r\nContent-Length: `
headers_pre_content_length_end:
    align 8

headers_last:
    db `\r\n\r\n`
headers_last_end:
    align 8

status_200:
    db "200 OK"
status_200_end:
    align 8

status_400:
    db "400 Bad Request"
status_400_end:
    db `\n`
status_400_line_end:
    align 8

status_404:
    db "404 Not Found"
status_404_end:
    db `\n`
status_404_line_end:
    align 8

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
    lea rdi, addr
    mov rsi, listen_addr
    mov rdx, 24
    call sockaddr_in_to_string
    add rax, listen_addr
    dec rax
    mov byte [rax], `\n`
    inc rax
    mov byte [rax], `\0`
    mov rdi, fd_stdout
    mov rsi, listen_msg
    call fd_puts
    mov rdi, self
    call nihserver_start_accepting
.done:
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 48
; struct nihserver *
%define self [rbp - 8]
; struct fd *
%define fd [rbp - 16]
; struct sockaddr_in
%define upeer_sockaddr [rbp - 32]
; int32_t
%define upeer_addrlen [rbp - 36]
; struct fd
%define upeer_fd [rbp - 40]
; void nihserver_start_accepting(struct nihserver *self);
nihserver_start_accepting:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    call nihserver_get_fd
    mov fd, rax
.while_true:
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
    add rax, peer_addr
    dec rax
    mov byte [rax], `\n`
    inc rax
    mov byte [rax], `\0`
    mov rdi, fd_stdout
    mov rsi, accept_msg
    call fd_puts
    mov rdi, self
    lea rsi, upeer_fd
    lea rdx, upeer_sockaddr
    call handle_connection
    jmp .while_true
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 4128
; struct nihserver *
%define self [rbp - 8]
; struct fd *
%define upeer_fd [rbp - 16]
; char *
%define buf_start [rbp - 24]
; struct sockaddr_in *
%define upeer_sockaddr [rbp - 32]
; char [4096]
%define buf [rbp - 4128]
; void nihserver_handle_connection(
;         struct nihserver *self,
;         struct fd *upeer_fd,
;         struct sockaddr_in *upeer_sockaddr
; );
handle_connection:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov self, rdi
    mov upeer_fd, rsi
    mov upeer_sockaddr, rdx
    lea rax, buf
    mov buf_start, rax
    mov rdi, upeer_fd
    call read_get
    cmp eax, 0
    jne .endif_read_e_0
    mov rdi, upeer_fd
    mov rsi, upeer_sockaddr
    mov rdx, status_400
    mov rcx, status_400_end - status_400
    mov r8, rdx
    mov r9, status_400_line_end - status_400
    call send_response_string
    jmp .done
.endif_read_e_0:

    mov rdi, upeer_fd
    mov rsi, hello
    mov rdx, helloend - hello
    call fd_write
    mov ebx, 0
    cmp eax, 0
    setge bl
    mov rdi, rbx
    mov rsi, 0
    call assert
.done:
    mov rdi, upeer_fd
    mov esi, SHUT_WR
    call fd_shutdown
    cmp eax, 0
    jne .fail
.do_while_read_g_0:
    mov rdi, upeer_fd
    lea rsi, buf
    mov rdx, 4096
    call fd_read
    cmp eax, 0
    jg .do_while_read_g_0
.fail:
    mov rdi, upeer_fd
    call fd_deinit
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 32
; struct fd *
%define fd [rbp - 8]
; uint64_t
%define num_read [rbp - 16]
; char[4]
%define buf [rbp - 20]
; char *
%define buf_ptr [rbp - 32]
; bool read_get(struct fd *fd);
read_get:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov fd, rdi
    mov qword num_read, 0
    lea rax, buf
    mov buf_ptr, rax
.while_num_read_l_4:
    mov rax, num_read
    cmp rax, 4
    jnl .endwhile_num_read_l_4
    mov rdi, fd
    mov rsi, buf_ptr
    mov rdx, 4
    sub rdx, num_read
    call fd_read
    cmp rax, 0
    jnle .endif_read_le_0
    mov rax, 0
    jmp .done
.endif_read_le_0:
    add num_read, rax
    jmp .while_num_read_l_4
.endwhile_num_read_l_4:
    lea rdi, buf
    mov rsi, get_string
    mov rdx, 4
    call mem_cmp
    mov ebx, 0
    cmp eax, 0
    sete bl
    mov eax, ebx
.done:
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 48
; struct fd *
%define fd [rbp - 8]
; struct sockaddr_in *
%define addr [rbp - 16]
; const char *
%define status [rbp - 24]
; uint64_t
%define status_size [rbp - 32]
; const char *
%define body [rbp - 40]
; uint64_t
%define body_size [rbp - 48]
; void send_response_string(
;         struct fd *fd,
;         struct sockaddr_in *addr,
;         const char *status,
;         uint64_t status_size,
;         const char *body,
;         uint64_t body_size
; );
send_response_string:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov fd, rdi
    mov addr, rsi
    mov status, rdx
    mov status_size, rcx
    mov body, r8
    mov body_size, r9
    mov r8, r9
    call send_headers
    cmp eax, 0
    je .done
    mov rdi, fd
    mov rsi, body
    mov rdx, body_size
    call fd_write_all
    cmp eax, 0
    je .done
    mov rdi, fd
    call fd_fsync
.done:
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 64
; struct fd *fd
%define fd [rbp - 8]
; struct sockaddr_in *
%define addr [rbp - 16]
; const char *
%define status [rbp - 24]
; uint64_t
%define status_size [rbp - 32]
; uint64_t
%define content_length [rbp - 40]
; char[21]
%define content_length_buf [rbp - 64]
; bool send_headers(
;         struct fd *fd,
;         struct sockaddr_in *addr,
;         const char *status,
;         uint64_t status_size,
;         uint64_t content_length
; );
send_headers:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov fd, rdi
    mov addr, rsi
    mov status, rdx
    mov status_size, rcx
    mov content_length, r8
    call print_response
    mov rdi, fd
    mov rsi, http_1_1
    mov rdx, http_1_1_end - http_1_1
    call fd_write_all
    cmp eax, 0
    je .done
    mov rdi, fd
    mov rsi, status
    mov rdx, status_size
    call fd_write_all
    cmp eax, 0
    je .done
    mov rdi, fd
    mov rsi, headers_pre_content_length
    mov rdx, headers_pre_content_length_end - headers_pre_content_length
    call fd_write_all
    cmp eax, 0
    je .done
    lea rdi, content_length_buf
    mov rsi, 21
    mov edx, content_length
    call string_from_uint64
    mov rdx, rax
    mov rdi, fd
    lea rsi, content_length_buf
    call fd_write_all
    cmp eax, 0
    je .done
    mov rdi, fd
    mov rsi, headers_last
    mov rdx, headers_last_end - headers_last
    call fd_write_all
.done:
    add rsp, frame_size
    pop rbp
    ret

%define frame_size 64
; struct fd *
%define fd [rbp - 8]
; struct sockaddr_in *
%define addr [rbp - 16]
; const char *
%define status [rbp - 24]
; uint64_t
%define status_size [rbp - 32]
; uint64_t
%define content_length [rbp - 40]
; char[24]
%define buf [rbp - 64]
; void print_response(
;         struct fd *fd,
;         struct sockaddr_in *addr,
;         const char *status,
;         uint64_t status_size,
;         uint64_t content_length
; );
; e.g. 200 OK (13 bytes) -> [127.0.0.1:12345] (fd 5)\n
;            ^^  ^^^^^^^^^^^^               ^^^^^^ ^^
first:
    db " ("
second:
    db " bytes) -> ["
third:
    db "] (fd "
fourth:
    db `)\n`
fifth:
align 8
print_response:
    push rbp
    mov rbp, rsp
    sub rsp, frame_size
    mov fd, rdi
    mov addr, rsi
    mov status, rdx
    mov status_size, rcx
    mov content_length, r8
    mov rdi, fd_stdout
    mov rsi, status
    mov rdx, status_size
    call fd_write
    mov rdi, fd_stdout
    mov rsi, first
    mov rdx, second - first
    call fd_write
    lea rdi, buf
    mov rsi, 24
    mov rdx, content_length
    call string_from_uint64
    mov rdx, rax
    mov rdi, fd_stdout
    lea rsi, buf
    call fd_write
    mov rdi, fd_stdout
    mov rsi, second
    mov rdx, third - second
    call fd_write
    mov rdi, addr
    lea rsi, buf
    mov rdx, 24
    call sockaddr_in_to_string
    mov rdx, rax
    mov rdi, fd_stdout
    lea rsi, buf
    call fd_write
    mov rdi, fd_stdout
    mov rsi, third
    mov rdx, fourth - third
    call fd_write
    mov rdi, fd
    lea rsi, buf
    mov rdx, 24
    call fd_to_string
    mov rdx, rax
    mov rdi, fd_stdout
    lea rsi, buf
    call fd_write
    mov rdi, fd_stdout
    mov rsi, fourth
    mov rdx, fifth - fourth
    call fd_write
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
