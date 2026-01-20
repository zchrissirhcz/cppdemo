#include "string_view.h"
#include "string_view.hpp"

const char* string_view_data(const StringView* view)
{
    return (view && view->ref) ? view->ref->c_str() : nullptr;
}

size_t string_view_length(const StringView* view)
{
    return (view && view->ref) ? view->ref->length() : 0;
}