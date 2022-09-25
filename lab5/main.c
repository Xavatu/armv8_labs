#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "grey_filter.h"
#include "stb/stb_image.h"
#include "stb/stb_image_write.h"


int main(int argc, char* argv[])
{
    if (argc != 4)
    {
        printf("usage: program %s input_file output_file output_file_asm", argv[0]);
        return 1;
    }

    const char* input_file = argv[1];
    const char* output_file = argv[2];
    const char* output_file_asm = argv[3];

    int width, height, channels;
    unsigned char *img = stbi_load(input_file, &width, &height, &channels, 0);
    if (!img) {
        printf("image %s load error\n", input_file);
        return 1;
    }
    if (channels != 3) {
        printf("image %s format error: expected 3 channels, got %d\n", input_file, channels);
        return 1;
    }
    printf("image uploaded: (%dpx/%dpx), %dch\n", width, height, channels);

    int img_size = width * height * channels;
    int res_channels = 1;
    int res_size = width * height * res_channels;
    unsigned char *res_img = (unsigned char *)malloc(res_size);

    clock_t start = clock();
    grey_filter(img, res_img, img_size);
    clock_t end = clock();
    double time = ((double) end - (double) start) / CLOCKS_PER_SEC;
    printf("C time: %lg\n", time);

    stbi_write_jpg(output_file, width, height, res_channels, res_img, 100);

    start = clock();
    grey_filter_asm(img, res_img, img_size);
    end = clock();
    time = ((double) end - (double) start) / CLOCKS_PER_SEC;
    printf("ASM Time: %lg\n", time);

    stbi_write_jpg(output_file_asm, width, height, res_channels, res_img, 100);

    stbi_image_free(img);
    free(res_img);

    return 0;
}
