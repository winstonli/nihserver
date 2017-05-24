%ifndef SOCKADDR_IN_I
%define SOCKADDR_IN_I

; struct sockaddr_in {
;     int16_t sin_family;
;     /* stored as big endian */
;     uint16_t sin_port;
;     uint32_t sin_addr;
;     int8_t sin_zero[8];
; };

%define SIZEOF_sockaddr_in 16

%define OFFSETOF_sockaddr_in_sin_family 0

%define OFFSETOF_sockaddr_in_sin_port 2

%define OFFSETOF_sockaddr_in_sin_addr 4

%define OFFSETOF_sockaddr_in_sin_zero 8

%ifndef SOCKADDR_IN_S

; void sockaddr_in_init(
;         struct sockaddr_in *self,
;         int16_t sin_family,
;         uint16_t sin_port_little_endian,
;         uint32_t sin_addr
; );
extern sockaddr_in_init

; void sockaddr_in_deinit(struct sockaddr_in *self);
extern sockaddr_in_deinit

%endif

%endif
