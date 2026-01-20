#include "cppdemo_string.h"

namespace cppdemo {

bool startsWith(std::string const& s, std::string const& prefix)
{
    return s.size() >= prefix.size() && std::equal(prefix.begin(), prefix.end(), s.begin());
}

bool endsWith(std::string const& s, std::string const& suffix)
{
    return s.size() >= suffix.size() && std::equal(suffix.rbegin(), suffix.rend(), s.rbegin());
}

} // namespace cppdemo