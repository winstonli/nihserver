%ifndef SYSCALL_I
%define SYSCALL_I

%define SYS_munmap 11
%define SYS_exit 60

%define AF_INET 2

%define SOCK_STREAM 1

%define SOL_SOCKET 1

%define SO_REUSEADDR 2

%define SHUT_RD 0
%define SHUT_WR 1
%define SHUT_RDWR 2

%define MSG_NOSIGNAL 16384

%define O_RDONLY 0

%define S_IRUSR 256

%define PROT_READ 1
%define PROT_WRITE 2
%define PROT_EXEC 4

%define MAP_SHARED 0x1
%define MAP_PRIVATE 0x2
%define MAP_ANONYMOUS 0x20
%define MAP_GROWSDOWN 0x100

%define CLONE_VM 0x100
%define CLONE_FS 0x200
%define CLONE_FILES 0x400
%define CLONE_SIGHAND 0x800
%define CLONE_THREAD 0x10000

%define SIGCHLD 0x11

%ifndef SYSCALL_S

; int32_t syscall_open(
;         const int8_t *filename,
;         int32_t flags,
;         int32_t mode
; );
extern syscall_open

; void *syscall_mmap(
;         void *addr,
;         uint64_t length,
;         uint64_t prot,
;         uint64_t flags,
;         int64_t fd,
;         int64_t offset
; );
extern syscall_mmap

; int32_t syscall_munmap(void *addr, uint64_t length);
extern syscall_munmap

; int32_t syscall_accept(
;         int32_t fd,
;         struct sockaddr *upeer_sockaddr,
;         int32_t *upeer_addrlen
; );
extern syscall_accept

; int32_t syscall_bind(int32_t fd, struct sockaddr *umyaddr, int32_t addrlen);
extern syscall_bind

; int64_t syscall_clone(
;         uint64_t flags,
;         void *child_stack,
;         pid_t *ptid,
;         pid_t *ctid
; );
extern syscall_clone

; int32_t syscall_close(int32_t fd);
extern syscall_close

; void syscall_exit(int32_t status);
extern syscall_exit

; int32_t syscall_fstat(int32_t fd, struct stat *statbuf);
extern syscall_fstat

; int32_t syscall_fsync(int32_t fd);
extern syscall_fsync

; int32_t syscall_listen(int32_t fd, int32_t backlog);
extern syscall_listen

; int32_t syscall_read(int32_t fd, int8_t *buf, uint64_t count);
extern syscall_read

; int64_t syscall_sendfile(
;         int32_t out_fd,
;         int32_t in_fd,
;         int64_t *offset,
;         uint64_t count
; );
extern syscall_sendfile

; int32_t syscall_sendto(
;         int32_t fd,
;         const void *buf,
;         uint64_t len,
;         int32_t flags,
;         const struct sockaddr *dest_addr,
;         uint64_t addrlen
; );
extern syscall_sendto

; int32_t syscall_setsockopt(
;         int32_t fd,
;         int32_t level,
;         int32_t optname,
;         int8_t *optval,
;         int32_t optlen
; );
extern syscall_setsockopt

; int32_t syscall_shutdown(int32_t fd, int32_t how);
extern syscall_shutdown

; int32_t syscall_socket(int family, int type, int protocol);
extern syscall_socket

; int32_t syscall_stat(const char *filename, struct stat *buf);
extern syscall_stat

; int32_t syscall_write(int32_t fd, const void *buf, uint64_t count);
extern syscall_write

%endif

%endif
