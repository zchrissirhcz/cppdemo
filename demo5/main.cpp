#include <stdio.h>
#include <math.h>
#include <string.h>
#if _MSC_VER
#include <Windows.h>
#endif
#include <algorithm>

void M_PI_demo()
{
    double radius = 5.0;
    double area = M_PI * radius * radius;
    printf("Area of circle with radius %.2f is %.2f\n", radius, area);
}

void CRT_SECURE_NO_WARNINGS_demo()
{
    // strcpy
    {
        const char* src = "Hello, World!";
        char dest[50];
        // Using strcpy without warnings due to CRT_SECURE_NO_WARNINGS
        strcpy(dest, src);
        printf("Copied string: %s\n", dest);
    }

    // fopen
    {
        const char* filename = "test.txt";
        FILE* file = fopen(filename, "w");
        if (file)
        {
            const char* content = "This is a test file.";
            fwrite(content, sizeof(char), strlen(content), file);
            fclose(file);
            printf("File '%s' created successfully.\n", filename);
        }
        else
        {
            printf("Failed to create file '%s'.\n", filename);
        }
    }
}

void min_max_demo()
{
    int a = 10;
    int b = 20;
    int minimum = std::min(a, b);
    int maximum = std::max(a, b);
    printf("Minimum of %d and %d is %d\n", a, b, minimum);
    printf("Maximum of %d and %d is %d\n", a, b, maximum);
}

int main()
{
    M_PI_demo();
    CRT_SECURE_NO_WARNINGS_demo();
    min_max_demo();
    return 0;
}