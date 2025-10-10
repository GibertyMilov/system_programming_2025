#include <stdio.h>
#include <stdlib.h>

int main(void){
    long long n;
    if(scanf("%lld", &n)!=1) return 1;
    long long sum = 0;
    for(long long k=1;k<=n;++k){
        long long t = k*(k+1);
        long long a = 3*k+1;
        
        long long b = 3*k+2;
        long long prod = t * a;
        prod = prod * b;

        if (k % 2 == 1) 
            sum -= prod;
        else
            sum += prod;
    }
    printf("%lld\n", sum);
    return 0;
}
