#include "text_file_reader.h" // C API
#include "../readlines/text_file_reader.hpp" // C++ implementation
#include <string>
#include "string_view.hpp"

struct TextFileReader_Impl
{
    cppdemo::TextFileReader reader;
    std::string line_data;
    StringView line_view;
    explicit TextFileReader_Impl(const std::string& filename) :
        reader(filename)
    {
        line_view.ref = &line_data;
    }
};

int TextFileReader_init(TextFileReader** out_reader, const char* filename)
{
    if (!out_reader || !filename) return -1;

    try {
        TextFileReader_Impl* impl = new TextFileReader_Impl(filename);
        *out_reader = reinterpret_cast<TextFileReader*>(impl);
        return 0;
    }
    catch (...)
    {
        return 1;
    }
}

bool TextFileReader_getline(TextFileReader* reader, StringView** out_line)
{
    if (!reader || !out_line) return false;

    TextFileReader_Impl* impl = reinterpret_cast<TextFileReader_Impl*>(reader);
    bool success = impl->reader.getline(impl->line_data);
    if (success)
    {
        *out_line = &impl->line_view;
        return true;
    }
    return false;
}

void TextFileReader_uninit(TextFileReader* reader)
{
    if (!reader) return;
    delete reinterpret_cast<TextFileReader_Impl*>(reader);
}