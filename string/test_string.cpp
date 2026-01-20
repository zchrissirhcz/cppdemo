#include "cppdemo_string.h"
#include <iostream>

int main()
{
    std::string const s = "Hello, World!";
    std::string const prefix = "Hello";
    std::string const suffix = "World!";

    std::cout << std::boolalpha << cppdemo::startsWith(s, prefix) << std::endl;
    std::cout << std::boolalpha << cppdemo::endsWith(s, suffix) << std::endl;

    return 0;
}