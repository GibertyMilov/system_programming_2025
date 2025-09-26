#include <stdio.h>
#include <stdint.h>

int main(void) {
    uint64_t N = 5277616985ULL;
    unsigned long long sum = 0;

    while (N > 0) {
        sum += N % 10;
        N  /= 10;
    }

    printf("%llu\n", sum);
    return 0;
}
