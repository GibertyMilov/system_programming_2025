#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void init_queue();
void enqueue(long val);
long dequeue();
void fill_random(long n);
long count_primes();
long* get_odd_numbers(long* size);
void remove_even_numbers();
void free_array(long* ptr, long size);

void print_queue() {
    long temp[1024];
    long count = 0;
    
    long val;
    while ((val = dequeue()) != 0) {
        temp[count++] = val;
    }
    
    printf("Текущая очередь: ");
    for (long i = 0; i < count; i++) {
        printf("%ld ", temp[i]);
        enqueue(temp[i]);
    }
    printf("(всего %ld элементов)\n", count);
}

int main() {
    init_queue();
    fill_random(10);
    
    printf("=== Тестирование очереди ===\n");
    
    printf("1. Исходная очередь: ");
    print_queue();
    
    printf("2. Подсчет простых чисел...\n");
    long prime_count = count_primes();
    printf("   Количество простых чисел: %ld\n", prime_count);
    
    printf("3. Очередь после count_primes: ");
    print_queue();
    
    printf("4. Получение нечетных чисел...\n");
    long odd_size;
    long* odd_numbers = get_odd_numbers(&odd_size);
    printf("   Нечетные числа (%ld шт.): ", odd_size);
    for (long i = 0; i < odd_size; i++) {
        printf("%ld ", odd_numbers[i]);
    }
    printf("\n");
    
    printf("5. Очередь после get_odd_numbers: ");
    print_queue();
    
    printf("6. Удаление четных чисел...\n");
    remove_even_numbers();
    
    printf("7. Очередь после remove_even_numbers: ");
    print_queue();
    
    if (odd_numbers != NULL) {
        free_array(odd_numbers, odd_size);
    }
    
    printf("=== Тест завершен успешно ===\n");
    return 0;
}