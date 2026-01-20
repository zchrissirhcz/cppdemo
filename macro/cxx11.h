#pragma once

#if __cplusplus >= 201100
#   define MY_CXX11
#elif defined(__cplusplus) && defined(_MSC_VER) && (_MSC_VER >= 1800)
#   define MY_CXX11
#endif