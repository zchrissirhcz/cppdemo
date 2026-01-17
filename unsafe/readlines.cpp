#include <string>
#include <stdio.h>
#include <fstream>
#include <vector>

bool create_crlf_file(const std::string& path, const std::vector<std::string>& lines)
{
    std::ofstream ofs(path, std::ios::binary);
    if (!ofs.is_open()) return false;
    for (const auto& line : lines)
        ofs << line << "\r\n";
    return true;
}

int main()
{
    const std::vector<std::string> lines = { "hello", "world" };
    const std::string path = "readlines_test.txt";
    create_crlf_file(path, lines);

    std::ifstream file(path);
    if (!file.is_open())
    {
        fprintf(stderr, "failed to open %s\n", path.c_str());
        return -1;
    }
    std::string line;
    int line_num = 0;
    while (std::getline(file, line))
    {
        line_num++;
        // MSVC drop '\n' and '\r', so after std::getline() it gives line without '\r' and '\n'
        // but GCC/Clang on Linux drop only '\n', i.e. keeps '\r' at the end of the line
        // and `\r` is not visible if you just print it in console, which may lead to confusion, e.g.
        // - reading an image file, but failed because of extra '\r' in the file path
        // - comparing two strings read from two files, but failed because of extra '\r' in one string
        // - etc.
        // so, when reading a CRLF text file (often created on Windows) with GCC/Clang on Linux,
        // we should always check and remove '\r' at the end of the line
        if (!line.empty() && line.back() == '\r')
        {
            line.pop_back(); // remove trailing '\r'
            printf("found \\r at the end of line %d\n", line_num);
        }
        //printf("%s\n", line.c_str());
    }
    return 0;
}