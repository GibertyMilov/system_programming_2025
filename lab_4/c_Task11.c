#include <stdio.h>

int main() {
    int n;
    printf("Введите количество судей n: ");
    scanf("%d", &n);
    
    int yes_votes = 0;
    for (int i = 0; i < n; i++) {
        int vote;
        printf("Введите голос судьи (0 или 1): ");
        scanf("%d", &vote);
        if (vote == 1) {
            yes_votes++;
        }
    }
    
    if (yes_votes * 2 > n) {
        printf("Решение: Да\n");
    } else if (yes_votes * 2 < n) {
        printf("Решение: Нет\n");
    } else {
        printf("Ничья! Решение не принято\n");
    }
    
    return 0;
}