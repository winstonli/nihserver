%ifndef NIHSERVER_I
%define NIHSERVER_I

; A struct containing an instance of a server.
; struct nihserver {
;     struct fd fd;
;     uint16_t port;
;     /* unowned */
;     const char *filepath;
;     uint64_t filepath_size;
;     int32_t num_threads;
; }

%define SIZEOF_nihserver 36

%define OFFSETOF_nihserver_fd 0

%define OFFSETOF_nihserver_port 8

%define OFFSETOF_nihserver_filepath 16

%define OFFSETOF_nihserver_filepath_size 24

%define OFFSETOF_nihserver_num_threads 32

%ifndef NIHSERVER_S

; void nihserver_init(
;         struct nihserver *self,
;         uint16_t port,
;         /* unowned */
;         const char *filepath,
;         uint64_t filepath_size,
;         int32_t num_threads
; );
extern nihserver_init

; void nihserver_deinit(struct nihserver *self);
extern nihserver_deinit

; int32_t nihserver_start(struct nihserver *self);
extern nihserver_start

%endif

%endif
