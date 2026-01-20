#include <pystring.h>
#include <stdio.h>

int main()
{
    std::string s1 = "hello world";
    if (pystring::startswith(s1, "hello"))
    {
        printf("yes, %s starts with hello\n", s1.c_str());
    }

    return 0;
}