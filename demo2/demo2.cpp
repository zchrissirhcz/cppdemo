#include <stdio.h>
#include <iostream>
#include "cpu.h"

int main() {
    printf("Hi, this is hello-world from android console app\n");
    std::cout << "hello world\n";

    int cpu_count = ncnn::get_cpu_count();
    std::cout << "there are " << cpu_count << " cpus" << std::endl;

    return 0;
}
