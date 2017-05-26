%define STAT_S

%include "nihserver/linux/stat.i"

; st_mode mask for the file type
%define __S_IFMT 0q170000

; Directory
%define __S_IFDIR 0q040000
; Character device
%define __S_IFCHR 0q020000
; Block device
%define __S_IFBLK 0q060000
; Regular file
%define __S_IFREG 0q100000
; FIFO
%define __S_IFIFO 0q010000
; Symbolic link
%define __S_IFLNK 0q120000
; Socket
%define __S_IFSOCK 0q140000

section .text

global stat_get_st_mode

global stat_get_st_size

global stat_is_dir

global stat_is_reg

stat_get_st_mode:
    mov eax, [rdi + OFFSETOF_stat_st_mode]
    ret

stat_get_st_size:
    mov rax, [rdi + OFFSETOF_stat_st_size]
    ret

stat_is_dir:
    call stat_get_st_mode
    mov ebx, 0
    and eax, __S_IFMT
    cmp eax, __S_IFDIR
    sete bl
    mov eax, ebx
    ret

stat_is_reg:
    call stat_get_st_mode
    mov ebx, 0
    and eax, __S_IFMT
    cmp eax, __S_IFREG
    sete bl
    mov eax, ebx
    ret
