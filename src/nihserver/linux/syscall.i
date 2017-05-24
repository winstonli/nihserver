%ifndef SYSCALL_I
%define SYSCALL_I

%define AF_INET 2

%define SOCK_STREAM 1

%ifndef SYSCALL_S

; int32_t syscall_accept(
;         int32_t fd,
;         struct sockaddr *upeer_sockaddr,
;         int32_t *upeer_addrlen
; );
extern syscall_accept

; int32_t syscall_bind(int32_t fd, struct sockaddr *umyaddr, int32_t addrlen);
extern syscall_bind

; int32_t syscall_close(int32_t fd);
extern syscall_close

; void syscall_exit(int32_t status);
extern syscall_exit

; int32_t syscall_fstat(int32_t fd, struct stat *statbuf);
extern syscall_fstat

; int32_t syscall_listen(int32_t fd, int32_t backlog);
extern syscall_listen

; int32_t syscall_read(int32_t fd, int8_t *buf, uint64_t count);
extern syscall_read

; int32_t syscall_socket(int family, int type, int protocol);
extern syscall_socket

; int32_t syscall_write(int32_t fd, const void *buf, uint64_t count);
extern syscall_write

%endif

%endif
