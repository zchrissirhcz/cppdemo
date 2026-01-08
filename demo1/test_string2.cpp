#include <iostream>

#if _MSC_VER
#   ifndef WIN32_LEAN_AND_MEAN
#       define WIN32_LEAN_AND_MEAN
#   endif
#include <windows.h>
#endif

int main()
{
#if _MSC_VER
    SetConsoleOutputCP(65001);
    // same as: SetConsoleOutputCP(CP_UTF8);
    SetConsoleCP(65001);
#endif

    printf("✓ loaded successfully\n"); // fail to show ✓
    std::cout << "✓ loaded successfully" << std::endl; // fail to show ✓

    std::cout << u8"✓ loaded successfully" << std::endl; // success to show ✓

    const std::string str = u8"✓ loaded successfully";
    printf("%s\n", str.c_str()); // success to show ✓

    const std::string str2 = "你好世界";
    printf("%s\n", str2.c_str()); // fail to show 你好世界 due to SetConsoleOutputCP(65001) and SetConsoleCP(65001)

    const std::string str3 = u8"你好世界";
    printf("%s\n", str3.c_str()); // success to show 你好世界

    const std::string str4 = str + u8"你好世界";
    printf("%s\n", str4.c_str());

    return 0;
}