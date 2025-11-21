#include <unistd.h>

void mydelay(int ms) {
    usleep(ms * 1000);
}