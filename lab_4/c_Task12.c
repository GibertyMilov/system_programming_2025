#include <stdio.h>
#include <string.h>

int main() {
    char number[100];
    printf("Введите число: ");
    scanf("%s", number);
    
    int len = strlen(number);
    int is_non_decreasing = 1;
    
    for (int i = 0; i < len - 1; i++) {
        if (number[i] > number[i + 1]) {
            is_non_decreasing = 0;
            break;
        }
    }
    
    if (is_non_decreasing) {
        printf("Да\n");
    } else {
        printf("Нет\n");
    }
    
    return 0;
}