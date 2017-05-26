%ifndef STRING_I
%define STRING_I

%ifndef STRING_S

; uint64_t string_from_int32(int8_t *s, uint64_t size, int32_t i);
extern string_from_int32

; uint64_t string_from_uint64(int8_t *s, uint64_t size, uint64_t u);
extern string_from_uint64

; bool string_to_int64(int8_t *s, uint64_t size, int64_t *out);
extern string_to_int64

; uint64_t string_length(int8_t *s);
extern string_length

%endif

%endif
