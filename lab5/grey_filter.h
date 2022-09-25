#ifndef GREY_FILTER_H
#define GREY_FILTER_H

unsigned char min(unsigned char, unsigned char);
unsigned char max(unsigned char, unsigned char);
void grey_filter(unsigned char*, unsigned char*, int);
void grey_filter_asm(unsigned char*, unsigned char*, int);

#endif //GREY_FILTER_H

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
