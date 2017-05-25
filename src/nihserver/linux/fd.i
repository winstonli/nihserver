%ifndef FD_I
%define FD_I

; We have this so we don't have to worry about whether an fd is valid or not.
; fd_deinit will just do the right thing.

; struct fd {
;     int32_t fd;
; }

%define SIZEOF_fd 4

%define OFFSETOF_fd_fd 0

%ifndef FD_S

; struct fd *stdin;
extern fd_stdin

; struct fd *stdout;
extern fd_stdout

; struct fd *stderr;
extern fd_stderr

; void fd_init(struct fd *self);
extern fd_init

; void fd_init_with_fd(struct fd *self, int32_t fd);
extern fd_init_with_fd

; int32_t fd_init_with_socket(
;         struct fd *self,
;         int32_t family,
;         int32_t type,
;         int32_t protocol
; );
extern fd_init_with_socket

; void fd_deinit(struct fd *self);
extern fd_deinit

; int32_t fd_accept(
;         struct fd *self,
;         struct sockaddr *upeer_sockaddr,
;         int32_t *upeer_addrlen,
;         /* uninitialized */
;         struct fd *upeer_fd
; );
extern fd_accept

; int32_t fd_bind(
;         struct fd *self,
;         const struct sockaddr *addr,
;         uint64_t addrlen
; );
extern fd_bind

; int32_t fd_fsync(struct fd *self);
extern fd_fsync

; int32_t fd_listen(struct fd *self, int32_t backlog);
extern fd_listen

; int32_t fd_read(struct fd *self, int8_t *buf, uint64_t count);
extern fd_read

; int32_t fd_sendto(
;         struct fd *self,
;         const void *buf,
;         uint64_t len,
;         int32_t flags,
;         const struct sockaddr *dest_addr,
;         uint64_t addrlen
; );
extern fd_sendto

; int32_t fd_setsockopt(
;         struct fd *self,
;         int32_t level,
;         int32_t optname,
;         int8_t *optval,
;         int32_t optlen
; );
extern fd_setsockopt

; int32_t fd_shutdown(struct fd *self, int32_t how);
extern fd_shutdown

; int32_t fd_write(struct fd *self, const void *buf, uint64_t count);
extern fd_write

; bool fd_send_all(struct fd *self, const void *buf, uint64_t count);
extern fd_send_all

; int32_t fd_putb(struct fd *self, uint8_t b);
extern fd_putb

; int32_t fd_putc(struct fd *self, int8_t c);
extern fd_putc

; int32_t fd_puti32(struct fd *self, int32_t i);
extern fd_puti32

; int32_t fd_putp(struct fd *self, const void *p);
extern fd_putp

; int32_t fd_puts(struct fd *self, const char *s);
extern fd_puts

; uint64_t fd_to_string(struct fd *self, int8_t *s, uint64_t size);
extern fd_to_string

%endif

%endif
