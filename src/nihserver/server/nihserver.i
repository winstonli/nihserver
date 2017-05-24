%ifndef NIHSERVER_I
%define NIHSERVER_I

; struct nihserver {
;     struct fd fd;
;     uint16_t port;
;     /* unowned */
;     const char *filepath;
; }

%define SIZEOF_nihserver 24

%define OFFSETOF_nihserver_fd 0

%define OFFSETOF_nihserver_port 8

%define OFFSETOF_nihserver_filepath 16

%ifndef NIHSERVER_S

; void nihserver_init(
;         struct nihserver *self,
;         uint16_t port,
;         /* unowned */
;         const char *filepath
; );
extern nihserver_init

; void nihserver_deinit(struct nihserver *self);
extern nihserver_deinit

; int32_t nihserver_start(struct nihserver *self);
extern nihserver_start

%endif

%endif
