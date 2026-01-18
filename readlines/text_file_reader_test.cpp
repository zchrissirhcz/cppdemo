#include "text_file_reader.hpp"
#include <iostream>
#include <stdlib.h>

#define CPPDEMO_REQUIRE(expr) \
    do { \
        if (!(expr)) { \
            std::cerr << "[FAILED] " << #expr \
                      << "\n   File: " << __FILE__ \
                      << "\n   Line: " << __LINE__ << std::endl; \
            std::exit(1);  \
        } else { \
            std::cout << "[PASS]   " << #expr << std::endl; \
        } \
    } while (0)

int main()
{
    // prepare text file: line ending is CRLF
    const char* test_path = "test_readlines.txt";
    std::ofstream ofs(test_path, std::ios::binary);
    const std::string lines[2] = {"hello", "world"};
    ofs << lines[0] << "\r\n" << lines[1] << "\r\n";
    ofs.close();

    // test the reader: each obtained line should not endswith '\r'
    cppdemo::TextFileReader reader(test_path);
    std::string line;
    while (reader.getline(line))
    {
        CPPDEMO_REQUIRE(line.back() != '\r');
    }
    return 0;
}