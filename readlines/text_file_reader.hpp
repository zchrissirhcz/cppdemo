#pragma once

#include <string>
#include <fstream>
#include <stdexcept>

namespace cppdemo {

// usage:
// TextFileReader reader("1.txt");
// std::string line;
// while (reader.getline(line))
//     std::cout << line << std::endl;
class TextFileReader
{
public:
    explicit TextFileReader(const std::string& filename): ifs_(filename)
    {
        if (!ifs_.is_open())
            throw std::runtime_error("failed to open file " + filename);
    }
    std::istream& getline(std::string& line)
    {
        std::getline(ifs_, line);
        if (!ifs_) return ifs_;
        // std::getline()'s default delimeter is '\n' (LF), GCC/Clang keeps '\r' if raw line endswith '\r\n' (CRLF) due to:
        //
        //         post-process when reading a line
        // ucrt    convert CRLF => LF
        // glibc   no conversion
        //
        // https://github.com/microsoft/STL/issues/2646
        // C:\Program Files (x86)\Windows Kits\10\Source\10.0.26100.0\ucrt\lowio\read.cpp, line 152
        // call stack:
        // std::getline() => std::istream::getline() => std::streambuf::sgetc() => std::filebuf::underflow() => _IO_file_xsgetn => fread() => fread_s() => _fread_nolock_s() => _read_nolock() => translate_text_mode_nolock()
        // https://github.com/microsoft/STL/blob/c865e85d77b9c802359212e8371c65a2f9d44722/stl/inc/string#L38C70-L38C75
        // this usually happens when GCC/Clang reading a text file which use CRLF as ending, most probably generated on Windows
        // and make it look like: "Linux GCC std::getline() keeps the annoying '\r' ending char, weird"
        if (!line.empty() && line.back() == '\r')
            line.pop_back();
        return ifs_;
    }
    TextFileReader(const TextFileReader&) = delete;
    TextFileReader& operator=(const TextFileReader&) = delete;
    TextFileReader(TextFileReader&&) = default;
    TextFileReader& operator=(TextFileReader&&) = default;
private:
    std::ifstream ifs_;
};

} // namespace cppdemo
