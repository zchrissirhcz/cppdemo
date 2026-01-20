#pragma once

#include "string_view.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct TextFileReader TextFileReader;

/// @brief Initialize the reader
/// @param filename 
/// @return 0 if success 
int TextFileReader_init(TextFileReader** out_reader, const char* filename);

bool TextFileReader_getline(TextFileReader* reader, StringView** out_line);

void TextFileReader_uninit(TextFileReader* reader);

#ifdef __cplusplus
}
#endif