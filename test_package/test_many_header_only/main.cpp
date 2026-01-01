#include "spdlog/spdlog.h"

#include <fmt/chrono.h>

void fmt_demo()
{
    auto now = std::chrono::system_clock::now();
    fmt::print("Date and time: {}\n", now);
    fmt::print("Time: {:%H:%M}\n", now);
}

void spdlog_demo() 
{
    spdlog::info("Welcome to spdlog!");
    spdlog::error("Some error message with arg: {}", 1);
    
    spdlog::warn("Easy padding in numbers like {:08d}", 12);
    spdlog::critical("Support for int: {0:d};  hex: {0:x};  oct: {0:o}; bin: {0:b}", 42);
    spdlog::info("Support for floats {:03.2f}", 1.23456);
    spdlog::info("Positional args are {1} {0}..", "too", "supported");
    spdlog::info("{:<30}", "left aligned");
    
    spdlog::set_level(spdlog::level::debug); // Set *global* log level to debug
    spdlog::debug("This message should be displayed..");    
    
    // change log pattern
    spdlog::set_pattern("[%H:%M:%S %z] [%n] [%^---%L---%$] [thread %t] %v");
    
    // Compile time log levels
    // Note that this does not change the current log level, it will only
    // remove (depending on SPDLOG_ACTIVE_LEVEL) the call on the release code.
    SPDLOG_TRACE("Some trace message with param {}", 42);
    SPDLOG_DEBUG("Some debug message");
}

#include <iostream>
//#include <filesystem>
//namespace fs = std::filesystem;

#include <ghc/filesystem.hpp>
namespace fs = ghc::filesystem;

void filesystem_demo()
{
    std::string path = ".";  // 要检查的目录路径
    bool exists = fs::exists(fs::path(path) / "readme.md");
    std::cout << (exists ? "找到" : "未找到") << " readme.md" << std::endl;
}

#include <CLI/CLI11.hpp>
#include <iostream>
#include <string>

int cli11_demo(int argc, const char* argv[])
{
    CLI::App app("K3Pi goofit fitter");
    // add version output
    app.set_version_flag("--version", std::string(CLI11_VERSION));
    std::string file;
    CLI::Option *opt = app.add_option("-f,--file,file", file, "File name");

    int count{0};
    CLI::Option *copt = app.add_option("-c,--count", count, "Counter");

    int v{0};
    CLI::Option *flag = app.add_flag("--flag", v, "Some flag that can be passed multiple times");

    double value{0.0};  // = 3.14;
    app.add_option("-d,--double", value, "Some Value");

    CLI11_PARSE(app, argc, argv);

    std::cout << "Working on file: " << file << ", direct count: " << app.count("--file")
              << ", opt count: " << opt->count() << '\n';
    std::cout << "Working on count: " << count << ", direct count: " << app.count("--count")
              << ", opt count: " << copt->count() << '\n';
    std::cout << "Received flag: " << v << " (" << flag->count() << ") times\n";
    std::cout << "Some value: " << value << '\n';

    return 0;
}

int main(int argc, const char* argv[])
{
    spdlog_demo();
    fmt_demo();
    filesystem_demo();
    cli11_demo(argc, argv);
    return 0;
}