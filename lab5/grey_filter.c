#include "grey_filter.h"

unsigned char min(unsigned char c1, unsigned char c2) {
    if (c1 <= c2) return c1;
    return c2;
}

unsigned char max(unsigned char c1, unsigned char c2) {
    if (c1 >= c2) return c1;
    return c2;
}

void grey_filter(unsigned char *img, unsigned char *res_img, int size) {
    unsigned char *res_ptr = res_img + size/6;
    int k = 0;
    unsigned char *r = img + size/2;
    for (unsigned char *p = img; p < img + size/2; p += 3) {
        unsigned char min_c = *p;
        unsigned char max_c = *p;
        for (int i = 1; i < 3; ++i) {
            min_c = min(min_c, *(p + i));
            max_c = max(max_c, *(p + i));
        }
        *res_ptr = ((int) min_c + (int) max_c) / 2;
        ++res_ptr;
        ++k;
    }
    res_ptr = res_img;
    for (unsigned char *p = img + size/2; p < img + size; p += 3) {
        unsigned char min_c = *p;
        unsigned char max_c = *p;
        for (int i = 1; i < 3; ++i) {
            min_c = min(min_c, *(p + i));
            max_c = max(max_c, *(p + i));
        }
        *res_ptr = ((int) min_c + (int) max_c) / 2;
        ++res_ptr;
        ++k;
    }
}
