#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
    const char* data; 
    size_t length;
} Line;

typedef struct {
    Line* lines; 
    size_t count;
} Lines;

int day1() {
    return 0;
}

int day2() {
    return 0;
}

int read_single_line(FILE* file, Line* line) {
    char *buffer = NULL;
    size_t buffer_size = 0;
    size_t num_chars = getline(&buffer, &buffer_size, file);
    if (num_chars == -1) {
        return 0;
    }
    line->data = buffer;
    line->length = num_chars-1; // drop newline
    return 1;
}

int main() {
    FILE* file = fopen("../input1.txt", "r");
    if (!file) {
        perror("Failed to open file");
        return 1;
    }
    Line line;
    while (read_single_line(file, &line)) {
        printf("%.*s\n", (int)line.length, line.data);
        free((void*)line.data);
    };

    
    // printf("%d", day1());
    // printf("%d", day2());
    return 0;
}
