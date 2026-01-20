#include "text_file_reader.h"
#include <stdio.h>

int main(void)
{
    TextFileReader* reader = NULL;
    StringView* line = NULL;
    
    if (TextFileReader_init(&reader, "test_readlines.txt") != 0) {
        fprintf(stderr, "Failed to open file\n");
        return 1;
    }
    
    while (TextFileReader_getline(reader, &line)) {
        printf("%s (len=%zu)\n", string_view_data(line), string_view_length(line));
    }
    
    TextFileReader_uninit(reader);
    
    return 0;
}