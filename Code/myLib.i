# 1 "myLib.c"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "myLib.c"
# 1 "myLib.h" 1




typedef unsigned short u16;
# 25 "myLib.h"
extern unsigned short *videoBuffer;
# 40 "myLib.h"
void setPixel(int row, int col, unsigned short color);
void drawRect(int row, int col, int height, int width, unsigned short color);
void fillScreen(unsigned short color);


void waitForVBlank();
# 66 "myLib.h"
extern unsigned short oldButtons;
extern unsigned short buttons;
# 78 "myLib.h"
typedef volatile struct {
    volatile const void *src;
    volatile void *dst;
    unsigned int cnt;
} DMA;


extern DMA *dma;
# 118 "myLib.h"
void DMANow(int channel, volatile const void *src, volatile void *dst, unsigned int cnt);




int collision(int rowA, int colA, int heightA, int widthA, int rowB, int colB, int heightB, int widthB);
# 2 "myLib.c" 2

unsigned short *videoBuffer = (unsigned short *)0x6000000;

DMA *dma = (DMA *)0x40000B0;

void setPixel(int row, int col, unsigned short color) {

 videoBuffer[((row)*(240)+(col))] = color;
}

void drawRect(int row, int col, int height, int width, unsigned short color) {
    for (int i = 0; i < height; i++) {
        volatile unsigned short c = color;
        dma[3].cnt = 0;
        dma[3].src = &c;
        dma[3].dst = &videoBuffer[((row + i)*(240)+(col))];
        dma[3].cnt = (1 << 31) | (2 << 23) | width;
    }
}

void fillScreen(unsigned short color) {
    volatile unsigned short c = color;
    dma[3].cnt = 0;
    dma[3].src = &c;
    dma[3].dst = videoBuffer;
    dma[3].cnt = (1 << 31) | (2 << 23) | 38400;
}

void waitForVBlank() {

 while((*(volatile unsigned short *)0x4000006) > 160);
 while((*(volatile unsigned short *)0x4000006) < 160);
}

void DMANow(int channel, volatile const void *src, volatile void *dst, unsigned int cnt) {

    dma[channel].cnt = 0;
    dma[channel].src = &src;
    dma[channel].dst = &dst;
    dma[channel].cnt = cnt | (1 << 31);
}

int collision(int rowA, int colA, int heightA, int widthA,
    int rowB, int colB, int heightB, int widthB) {

    return (rowA < (rowB + heightB - 1)) && ((rowA + heightA - 1) > (rowB))
        && (((colA) < (colB + widthB - 1)) && (colA + widthA - 1) > (colB));
}
