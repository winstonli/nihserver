%ifndef STAT_I
%define STAT_I

; struct stat {
;     dev_t     st_dev;     /* ID of device containing file */
;     ino_t     st_ino;     /* inode number */
;     mode_t    st_mode;    /* protection */ /* uint32_t */
;     nlink_t   st_nlink;   /* number of hard links */
;     uid_t     st_uid;     /* user ID of owner */
;     gid_t     st_gid;     /* group ID of owner */
;     dev_t     st_rdev;    /* device ID (if special file) */
;     off_t     st_size;    /* total size, in bytes */ /* int64_t */
;     blksize_t st_blksize; /* blocksize for file system I/O */
;     blkcnt_t  st_blocks;  /* number of 512B blocks allocated */
;     time_t    st_atime;   /* time of last access */
;     time_t    st_mtime;   /* time of last modification */
;     time_t    st_ctime;   /* time of last status change */
; };

%define SIZEOF_stat 144

%define OFFSETOF_stat_st_mode 24

%define OFFSETOF_stat_st_size 48

%ifndef STAT_S

; uint32_t stat_get_st_mode(struct stat *self);
extern stat_get_st_mode

; int64_t stat_get_st_size(struct stat *self);
extern stat_get_st_size

; bool stat_is_dir(struct stat *self);
extern stat_is_dir

; bool stat_is_reg(struct stat *self);
extern stat_is_reg

%endif

; #define __S_IFMT    0170000 /* These bits determine file type.  */
;
;  /* File types.  */
;  #define __S_IFDIR   0040000 /* Directory.  */
;  #define __S_IFCHR   0020000 /* Character device.  */
;  #define __S_IFBLK   0060000 /* Block device.  */
;  #define __S_IFREG   0100000 /* Regular file.  */
;  #define __S_IFIFO   0010000 /* FIFO.  */
;  #define __S_IFLNK   0120000 /* Symbolic link.  */
;  #define __S_IFSOCK  0140000 /* Socket.  */
;
;  #define __S_ISTYPE(mode, mask)  (((mode) & __S_IFMT) == (mask))
;
;  #define S_ISDIR(mode)    __S_ISTYPE((mode), __S_IFDIR)
;  #define S_ISCHR(mode)    __S_ISTYPE((mode), __S_IFCHR)
;  #define S_ISBLK(mode)    __S_ISTYPE((mode), __S_IFBLK)
;  #define S_ISREG(mode)    __S_ISTYPE((mode), __S_IFREG)
;  #ifdef __S_IFIFO
;  # define S_ISFIFO(mode)  __S_ISTYPE((mode), __S_IFIFO)
;  #endif
;  #ifdef __S_IFLNK
;  # define S_ISLNK(mode)   __S_ISTYPE((mode), __S_IFLNK)
;  #endif
;
;  #if defined __x86_64__ && defined __ILP32__
;  # define __SYSCALL_SLONG_TYPE   __SQUAD_TYPE
;  # define __SYSCALL_ULONG_TYPE   __UQUAD_TYPE
;  #else
;  # define __SYSCALL_SLONG_TYPE   __SLONGWORD_TYPE
;  # define __SYSCALL_ULONG_TYPE   __ULONGWORD_TYPE
;  #endif
;
;  #define __DEV_T_TYPE        __UQUAD_TYPE
;  #define __UID_T_TYPE        __U32_TYPE
;  #define __GID_T_TYPE        __U32_TYPE
;  #define __INO_T_TYPE        __SYSCALL_ULONG_TYPE
;  #define __INO64_T_TYPE      __UQUAD_TYPE
;  #define __MODE_T_TYPE       __U32_TYPE
;  #ifdef __x86_64__
;  # define __NLINK_T_TYPE     __SYSCALL_ULONG_TYPE
;  # define __FSWORD_T_TYPE    __SYSCALL_SLONG_TYPE
;  #else
;  # define __NLINK_T_TYPE     __UWORD_TYPE
;  # define __FSWORD_T_TYPE    __SWORD_TYPE
;  #endif
;  #define __OFF_T_TYPE        __SYSCALL_SLONG_TYPE
;  #define __OFF64_T_TYPE      __SQUAD_TYPE
;  #define __PID_T_TYPE        __S32_TYPE
;  #define __RLIM_T_TYPE       __SYSCALL_ULONG_TYPE
;  #define __RLIM64_T_TYPE     __UQUAD_TYPE
;  #define __BLKCNT_T_TYPE     __SYSCALL_SLONG_TYPE
;  #define __BLKCNT64_T_TYPE   __SQUAD_TYPE
;  #define __FSBLKCNT_T_TYPE   __SYSCALL_ULONG_TYPE
;  #define __FSBLKCNT64_T_TYPE __UQUAD_TYPE
;  #define __FSFILCNT_T_TYPE   __SYSCALL_ULONG_TYPE
;  #define __FSFILCNT64_T_TYPE __UQUAD_TYPE
;  #define __ID_T_TYPE     __U32_TYPE
;  #define __CLOCK_T_TYPE      __SYSCALL_SLONG_TYPE
;  #define __TIME_T_TYPE       __SYSCALL_SLONG_TYPE
;  #define __USECONDS_T_TYPE   __U32_TYPE
;  #define __SUSECONDS_T_TYPE  __SYSCALL_SLONG_TYPE
;  #define __DADDR_T_TYPE      __S32_TYPE
;  #define __KEY_T_TYPE        __S32_TYPE
;  #define __CLOCKID_T_TYPE    __S32_TYPE
;  #define __TIMER_T_TYPE      void *
;  #define __BLKSIZE_T_TYPE    __SYSCALL_SLONG_TYPE
;  #define __FSID_T_TYPE       struct { int __val[2]; }
;  #define __SSIZE_T_TYPE      __SWORD_TYPE
;  #define __CPU_MASK_TYPE     __SYSCALL_ULONG_TYPE
;
;
;
;  #define __S16_TYPE      short int
;  #define __U16_TYPE      unsigned short int
;  #define __S32_TYPE      int
;  #define __U32_TYPE      unsigned int
;  #define __SLONGWORD_TYPE    long int
;  #define __ULONGWORD_TYPE    unsigned long int
;  #if __WORDSIZE == 32
;  # define __SQUAD_TYPE       __quad_t
;  # define __UQUAD_TYPE       __u_quad_t
;  # define __SWORD_TYPE       int
;  # define __UWORD_TYPE       unsigned int
;  # define __SLONG32_TYPE     long int
;  # define __ULONG32_TYPE     unsigned long int
;  # define __S64_TYPE     __quad_t
;  # define __U64_TYPE     __u_quad_t
;  /* We want __extension__ before typedef's that use nonstandard base types
;     such as `long long' in C89 mode.  */
;  # define __STD_TYPE     __extension__ typedef
;  #elif __WORDSIZE == 64
;  # define __SQUAD_TYPE       long int
;  # define __UQUAD_TYPE       unsigned long int
;  # define __SWORD_TYPE       long int
;  # define __UWORD_TYPE       unsigned long int
;  # define __SLONG32_TYPE     int
;  # define __ULONG32_TYPE     unsigned int
;  # define __S64_TYPE     long int
;  # define __U64_TYPE     unsigned long int
;  /* No need to mark the typedef with __extension__.   */
;  # define __STD_TYPE     typedef
;  #else
;  # error
;  #endif

%endif
