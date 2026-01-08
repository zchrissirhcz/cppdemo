#include <stdio.h>
#include <vector>

#if _MSC_VER
#   ifndef WIN32_LEAN_AND_MEAN
#       define WIN32_LEAN_AND_MEAN
#   endif
#include <windows.h>
#endif

// 如果没有指定 /source-charset:utf-8 但希望打印中文字符串
// 则需要先将 UTF-8 字符串转换为 UTF-16 字符串，再转换为 GBK 字符串, 然后输出
void print_utf8_in_gbk_console(const char* utf8_msg)
{
    int wide_char_size = MultiByteToWideChar(CP_UTF8, 0, utf8_msg, -1, nullptr, 0);
    std::vector<wchar_t> wide_text(wide_char_size);
    MultiByteToWideChar(CP_UTF8, 0, utf8_msg, -1, wide_text.data(), wide_char_size);
    int utf8_size = WideCharToMultiByte(936, 0, wide_text.data(), -1, nullptr, 0, nullptr, nullptr);
    std::vector<char> utf8_text(utf8_size);
    WideCharToMultiByte(936, 0, wide_text.data(), -1, utf8_text.data(), utf8_size, nullptr, nullptr);
    printf("%s", utf8_text.data());
}

int main()
{
    printf("你好世界\n");
    print_utf8_in_gbk_console("你好世界\n");
    return 0;
}