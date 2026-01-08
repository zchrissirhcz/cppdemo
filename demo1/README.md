# UTF-8 编码说明

## 1. 编译警告 C4819

test_comment.cpp

注释含有奇数个中文， 并且没有开启 UNICODE 字符集。

CMake 生成的 VS 工程，默认用 MBCS (Multi-Byte-Character-Set)，而不是 UNICODE，因此问题似乎比较常见。

复现：
- 系统是 Windows 11， 系统语言是中文，没有全局改用 UTF-8
- 代码用 UTF-8 编码保存
- 没有设置如下任何编译选项
```cpp
add_compile_options("/source-charset:utf-8")
add_compile_options("/execution-charset:utf-8")
add_compile_options("/utf-8")
```

报错举例：
```
D:\github\cppdemo\demo1\test_string2.cpp(1): warning C4819: 该文件包含不能在当前代码页(936)中表示的字符。请将该文件保存为 Unicode 格式以防止数据丢失
```
特点：一定是文件第1行。 说明是把整个源文件当做一个字符串扫描时报告的。
即: 报错形如:
> xxx.cpp(1): warning C4819: 


解决方法:
```cmake
if(MSVC)
    add_compile_options("/source-charset:utf-8")
endif()
```

或者:
```cmake
if(MSVC)
    add_definitions(-DUNICODE -D_UNICODE)
endif()
```

## 2. 运行环境，想显示 unicode

基本前提：
- 源代码用 UTF-8 编码保存， 而不是 UTF-8(BOM），更不是 GBK 或 GB2312
- 系统语言是中文， 没有启用全局的 UTF-8

有两种思路来配置 C++ 开发环境(运行程序阶段）的 UTF-8 编码：

1）最小化配置，够用即可。
编译选项用 `/source-charset:utf-8`， 不用 `/execution-charset:utf-8`, 也不用 `/utf-8`.
这样的话，VS调试时控制台打印中文也能正常显示。
```cmake
if(MSVC)
    add_compile_options("/source-charset:utf-8")
endif()
```
此时如果C++代码字符串中有中文，希望在控制台打印正常显示，则需要把 UTF-8 转为 UTF-16 再转为 GBK， 具体参照 test_string2.cpp 文件:
```cpp
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
```

并且，需要忍耐 warning:
```
D:\github\cppdemo\demo1\test_string2.cpp(7): warning C4566: 由通用字符名称“\u2713”表示的字符不能在当前代码页(936)中表示出来
D:\github\cppdemo\demo1\test_string2.cpp(10): warning C4566: 由通用字符名称“\u2717”表示的字符不能在当前代码页(936)中表示出来
```
但其实一定要输出， 也是可以的，用 u8"" 前缀的 C++ 编译器字符串即可， 
**u8 前缀只能用于字符串字面量 ，不能加到 std::string 变量上。它的作用是告诉编译器："不要转换这个字符串，保持 UTF-8 编码"**
具体参考 test_string2.cpp。


2）启用 unicode 字符。
编译选项用 `/utf-8`, 或者分别开启 `/source-charset:utf-8` 和 `/execution-charset:utf-8`.
```cmake
if(MSVC)
    add_compile_options("/utf-8")
    # 或: add_compile_options("/source-charset:utf-8;/execution-charset:utf-8")
endif()
```

好处是能看到 "花里胡哨" 的 unicode 字符：
```bash
✔ 你好世界
  ✅ 成功  ❌ 失败  ⚠️ 警告  ℹ️ 信息
```


### 2.1 终端配置 - PowerShell

这一步的目的：
- 让终端正常显示 unicode 字符
- 终端重定向到文件时， 希望保持 UTF-8 编码， 使得文件内容也正常显示 unicode 字符

进入 PowerShell, 编辑配置文件:
```bash
code $PROFILE
```

增加内容
```pwsh
# 设置默认编码为 UTF-8
function Enable-UTF8Console {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $global:OutputEncoding = [System.Text.Encoding]::UTF8
    $global:PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
    $global:PSDefaultParameterValues['*:Encoding'] = 'utf8'
    chcp 65001 | Out-Null
}

# 加载（执行一次）
Enable-UTF8Console
```

如果安装了 PowerShell7, 配置文件不同, 需要进入 pwsh 另行配置

- %USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
- %USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

验证:

```bash
PS D:> echo $OutputEncoding

BodyName          : utf-8
EncodingName      : Unicode (UTF-8)
HeaderName        : utf-8
WebName           : utf-8
WindowsCodePage   : 1200
IsBrowserDisplay  : True
IsBrowserSave     : True
IsMailNewsDisplay : True
IsMailNewsSave    : True
IsSingleByte      : False
EncoderFallback   : System.Text.EncoderReplacementFallback
DecoderFallback   : System.Text.DecoderReplacementFallback
IsReadOnly        : True
CodePage          : 65001
```

### 2.2 Visual Studio 运行程序

Visual Studio 运行程序时弹窗的终端， 并不加载 PowerShell 的 `$PROFILE` 文件，因而对于系统语言为中文的情况， 仍然是 CodePage 为 936， 解决方法是在 C++ 代码中临时修改为 UTF-8 （65001）.

foo.cpp:
```cpp
#include "utf8console.h"

#include <stdio.h>
int main()
{
    printf("✔ 你好世界\n");
    printf("  ✅ 成功  ❌ 失败  ⚠️ 警告  ℹ️ 信息\n");
}
```

utf8console.h 内容如下：
```cpp
#pragma once

#if _MSC_VER
#ifndef WIN32_LEAN_AND_MEAN
#   define WIN32_LEAN_AND_MEAN
#endif
#include <Windows.h>

namespace {

struct UTF8Console {
    UTF8Console() {
        SetConsoleOutputCP(65001);
        SetConsoleCP(65001);
    }
} g_utf8console_instance;

} // namespace

#endif // _MSC_VER
```

## 最佳实践

1. CMakeLists.txt, 启用 `/utf8`

2. VSCode 或终端运行程序： PowerShell 修改配置， 编码改为 UTF-8

3. VS 运行程序： C++ 代码， 包含 `utf8console.h` 头文件

意思是说，如果用2，VSCode作为开发环境，并不需要3 utf8console.h 文件， 反之亦然。
