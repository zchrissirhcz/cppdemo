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
        if (!line.empty() && line.back() == '\r')
        {
            line.pop_back();
            printf("found \\r at the end of line %d\n", line_num);
        }
        //printf("%s\n", line.c_str());
    }
    return 0;
}