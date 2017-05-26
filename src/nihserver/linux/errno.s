%define ERRNO_S

%include "nihserver/linux/errno.i"

section .data

unknown:
    db `Unknown error\0`
eperm:
    db `Operation not permitted\0`
enoent:
    db `No such file or directory\0`
esrch:
    db `No such process\0`
eintr:
    db `Interrupted system call\0`
eio:
    db `I/O error\0`
enxio:
    db `No such device or address\0`
e2big:
    db `Argument list too long\0`
enoexec:
    db `Exec format error\0`
ebadf:
    db `Bad file number\0`
echild:
    db `No child processes\0`
eagain:
    db `Try again\0`
enomem:
    db `Out of memory\0`
eacces:
    db `Permission denied\0`
efault:
    db `Bad address\0`
enotblk:
    db `Block device required\0`
ebusy:
    db `Device or resource busy\0`
eexist:
    db `File exists\0`
exdev:
    db `Cross-device link\0`
enodev:
    db `No such device\0`
enotdir:
    db `Not a directory\0`
eisdir:
    db `Is a directory\0`
einval:
    db `Invalid argument\0`
enfile:
    db `File table overflow\0`
emfile:
    db `Too many open files\0`
enotty:
    db `Not a typewriter\0`
etxtbsy:
    db `Text file busy\0`
efbig:
    db `File too large\0`
enospc:
    db `No space left on device\0`
espipe:
    db `Illegal seek\0`
erofs:
    db `Read-only file system\0`
emlink:
    db `Too many links\0`
epipe:
    db `Broken pipe\0`
edom:
    db `Math argument out of domain of func\0`
erange:
    db `Math result not representable\0`

errno_table:
    dq unknown
    dq eperm
    dq enoent
    dq esrch
    dq eintr
    dq eio
    dq enxio
    dq e2big
    dq enoexec
    dq ebadf
    dq echild
    dq eagain
    dq enomem
    dq eacces
    dq efault
    dq enotblk
    dq ebusy
    dq eexist
    dq exdev
    dq enodev
    dq enotdir
    dq eisdir
    dq einval
    dq enfile
    dq emfile
    dq enotty
    dq etxtbsy
    dq efbig
    dq enospc
    dq espipe
    dq erofs
    dq emlink
    dq epipe
    dq edom
    dq erange
errno_table_end:

section .text

global errno_to_string

errno_to_string:
    cmp rdi, 0
    jl .endif_errno_ge_0_and_errno_l_size
    cmp rdi, errno_table_end - errno_table
    jge .endif_errno_ge_0_and_errno_l_size
    lea rax, [errno_table + 8 * rdi]
    mov rax, [rax]
    jmp .done
.endif_errno_ge_0_and_errno_l_size:
    mov rax, unknown
.done:
    ret
