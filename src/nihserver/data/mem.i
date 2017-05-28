%ifndef MEM_I
%define MEM_I

%define MEM_CHUNK_SIZE (1 << 16)

%ifndef MEM_S

; void mem_copy(void *dest, const void *src, uint64_t n);
extern mem_copy

; int32_t mem_cmp(const void *a, const void *b, uint64_t n);
extern mem_cmp

; void *mem_alloc_chunk();
extern mem_alloc_chunk

; void mem_free_chunk(void *ptr);
extern mem_free_chunk

%endif

%endif
