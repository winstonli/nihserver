%ifndef MEM_I
%define MEM_I

%ifndef MEM_S

; void mem_copy(void *dest, const void *src, uint64_t n);
extern mem_copy

; int32_t mem_cmp(const void *a, const void *b, uint64_t n);
extern mem_cmp

%endif

%endif
