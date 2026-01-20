#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef struct StringView StringView;

const char* string_view_data(const StringView* view);
size_t string_view_length(const StringView* view);

#ifdef __cplusplus
}
#endif