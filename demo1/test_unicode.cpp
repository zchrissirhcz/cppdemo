#include <fmt/core.h>
#include <fmt/format.h>

#include <string>
#include <vector>
#include <utility>
#include <iostream>

int main()
{
    // 1. 基础 Unicode 输出
    fmt::print("═══════════════════════════════\n");
    fmt::print("│  多语言 Unicode 演示        │\n");
    fmt::print("═══════════════════════════════\n");
    
    fmt::print("fmt::print: 你好 안녕하세요\n");
    printf("printf: 你好 안녕하세요\n");
    std::cout << "u8 string: " << u8"你好 안녕하세요" << std::endl;

    // 2. 多语言文本 (C++11 风格)
    std::vector<std::pair<std::string, std::string> > greetings;
    greetings.push_back(std::make_pair("中文", "你好"));
    greetings.push_back(std::make_pair("日本語", "こんにちは"));
    greetings.push_back(std::make_pair("한국어", "안녕하세요"));
    greetings.push_back(std::make_pair("Русский", "Привет"));
    greetings.push_back(std::make_pair("العربية", "مرحبا"));
    
    for (size_t i = 0; i < greetings.size(); ++i) {
        fmt::print("{:>10}: {}\n", greetings[i].first, greetings[i].second);
    }
    
    // 3. Emoji 表格
    fmt::print("\n状态图标:\n");
    fmt::print("  ✅ 成功  ❌ 失败  ⚠️ 警告  ℹ️ 信息\n");
    
    // 4. Unicode 符号
    fmt::print("\n🚀 程序执行完毕!\n");
    
    // 5. 数学符号
    fmt::print("\n数学公式: ∑(i=1→n) i² = n(n+1)(2n+1)/6\n");
    fmt::print("希腊字母: α β γ δ ε ζ η θ\n");
    
    // 6. 箱形绘图字符
    fmt::print("\n┌─────────────────┐\n");
    fmt::print("│  Unicode 框架   │\n");
    fmt::print("└─────────────────┘\n");
    
    return 0;
}