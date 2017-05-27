%ifndef MEM_I
%define MEM_I

%define MiB_8 (1 << 16)

%ifndef MEM_S

; void mem_copy(void *dest, const void *src, uint64_t n);
extern mem_copy

; int32_t mem_cmp(const void *a, const void *b, uint64_t n);
extern mem_cmp

; void *mem_alloc_8m();
extern mem_alloc_8m

; void mem_free_8m(void *ptr);
extern mem_free_8m

%endif

%endif
