%ifndef FD_I
%define FD_I

; We have this so we don't have to worry about whether an fd is valid or not.
; fd_deinit will just do the right thing.

; struct fd {
;     int32_t fd;
; }

%define SIZEOF_fd 8

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

; int32_t fd_init_with_socket(
;         struct fd *self,
;         int32_t family,
;         int32_t type,
;         int32_t protocol
; );
extern fd_init_with_socket

; void fd_deinit(struct fd *self);
extern fd_deinit

; int32_t fd_bind(
;         struct fd *self,
;         const struct sockaddr *addr,
;         uint64_t addrlen
; );
extern fd_bind

;

; int32_t fd_write(struct fd *self, const void *buf, uint64_t count);
extern fd_write

; int32_t fd_putb(struct fd *self, uint8_t b);
extern fd_putb

; int32_t fd_putc(struct fd *self, int8_t c);
extern fd_putc

; int32_t fd_putp(struct fd *self, const void *p);
extern fd_putp

; int32_t fd_puts(struct fd *self, const char *s);
extern fd_puts

%endif

%endif
