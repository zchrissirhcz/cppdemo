#include <iostream>
#include <cereal/archives/json.hpp>
#include <cereal/types/vector.hpp>
#include <sstream>

struct Point
{
    int x;
    int y;
};

template <class Archive>
void serialize(Archive& ar, Point& p)
{
    ar(cereal::make_nvp("x", p.x));
    ar(cereal::make_nvp("y", p.y));
}

int main()
{
    Point p{10, 20};

    std::ostringstream oss;
    {
        cereal::JSONOutputArchive archive(oss);
        archive(cereal::make_nvp("p", p));
    }

    std::cout << oss.str() << std::endl;

    return 0;
}
