#define MAJOR 1
#define MINOR 2
#define PATCH 3

// make `x` as string, without expanding `x`
#define STRINGIFY_(x) #x

// first expand `x` then make it as string
#define STRINGIFY(x) STRINGIFY_(x)

#include <stdio.h>

void demo_stringify()
{
    const char* version1 = STRINGIFY_(MAJOR.MINOR.PATCH);
    printf("version1: %s\n", version1);

    const char* version2 = STRINGIFY(MAJOR.MINOR.PATCH);
    printf("version2: %s\n", version2);   
}




enum StateCode
{
    STATE_OK = 0,
    STATE_INVALID_PARAM = 1,
    STATE_TIMEOUT = 2,
    STATE_NULL_POINTER = 3
};

#define ENUM_CASE(name) case name: return #name;

const char* state_code_to_string(StateCode code)
{
    switch (code)
    {
        ENUM_CASE(STATE_OK);
        ENUM_CASE(STATE_INVALID_PARAM);
        ENUM_CASE(STATE_TIMEOUT);
        ENUM_CASE(STATE_NULL_POINTER);
    }
    return nullptr;
}

void demo_enum_to_str()
{
    printf("%s\n", state_code_to_string(STATE_OK));
    printf("%s\n", state_code_to_string(STATE_INVALID_PARAM));
    printf("%s\n", state_code_to_string(STATE_TIMEOUT));
    printf("%s\n", state_code_to_string(STATE_NULL_POINTER));
}




#include <cstdlib>

#define MY_REQUIRE(condition) \
    if (!(condition)) { \
        fprintf(stderr, "Assertion failed: %s, file %s, line %d\n", \
            #condition, __FILE__, __LINE__); \
        std::exit(1); \
    }

void demo_assert()
{
    void* ptr = NULL;
    MY_REQUIRE(ptr != NULL);
}


int main()
{
    demo_stringify();
    demo_enum_to_str();
    demo_assert();

    return 0;
}