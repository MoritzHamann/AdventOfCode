#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ctype.h>
#include <errno.h>

typedef enum LineType {
    EMPTY_LINE,
    NUMBER,
    ERROR,
    END_OF_FILE
} LineType;

typedef struct Line {
    LineType type;
    long value;
} Line;

typedef struct LineReader {
    char* buffer;
    size_t capacity;
    FILE* file;
    bool done;
} LineReader;

static bool is_empty_line(const char* line, size_t length) {
    for (size_t i = 0; i < length; i++) {
        if (!isspace((unsigned char)line[i])) {
            return false;
        }
    }
    return true;
}

static Line LineReader_next(LineReader* reader) {
    if (reader->done) return (Line) { .type = ERROR, .value = 0};

    long num_c = getline(&reader->buffer, &reader->capacity, reader->file);
    if (num_c < 0) {
        if (feof(reader->file)) {
            reader->done = true;
            return (Line){ .type = END_OF_FILE, .value = 0 };
        }

        return (Line) {.type = ERROR, .value = 0};
    }

    size_t line_length = (size_t)num_c;

    // check for empty line
    if (is_empty_line(reader->buffer, line_length)) {
        return (Line) {.type = EMPTY_LINE, .value = 0};
    }

    // convert to number
    errno = 0;
    char* end;
    long number = strtol(reader->buffer, &end, 10);
    if (number < 0 || errno != 0 || reader->buffer == end || (*end != '\n' && *end != '\0')) {
        return (Line) { .type= ERROR, .value = 0};
    }

    return (Line) {.type = NUMBER, .value = number};
}

static long compute_calories_for_elf(LineReader *reader) {
    long total = 0;
    Line line;

    while (!reader->done) {
        line = LineReader_next(reader);
        switch (line.type) {
            case NUMBER: 
                total += line.value;
                break;
            case EMPTY_LINE:
                return total;
            case ERROR:
                perror("error during file read");
                return -1;
            case END_OF_FILE:
                return total;
        }
    }
    return total;
}


static long day1(FILE* file) {
    long maximum = 0;

    LineReader reader = {
        .file = file,
        .buffer = NULL,
        .capacity = 0,
        .done = false
    };

    while (!reader.done) {
        int total = compute_calories_for_elf(&reader);
        if (total == -1) {
            return -1;
        }
        if (total > maximum) {
            maximum = total;
        }

    }

    return maximum;
}

// simple heap to track the maximums
typedef struct MaxArray {
    size_t size;
    // sorted descending
    long* values;
} MaxArray;

MaxArray* MaxArray_new(size_t size) {
    long* values = malloc(sizeof(long) * size);
    if (values == NULL) {
        perror("Unable to allocate MaxArray values");
        exit(1);
    }
    for (size_t i = 0; i < size; i++) {
        values[i] = 0;
    }

    MaxArray* heap = malloc(sizeof(MaxArray));
    if (heap == NULL) {
        perror("Unable to allocate MaxArray");
        exit(1);
    }

    heap->values = values;
    heap->size = size;
    return heap;
}

void MaxArray_add_value(MaxArray* heap, long value) {
    for (size_t i = 0; i < heap->size; i++) {
        if (heap->values[i] < value) {
            long last = heap->values[i];
            heap->values[i] = value;
            value = last;
        }
    }
}

void MaxArray_delete(MaxArray *array) {
    free(array->values);
}

static long day2(FILE* file) {
    MaxArray *maximums = MaxArray_new(3);

    LineReader reader = {
        .file = file,
        .buffer = NULL,
        .capacity = 0,
        .done = false
    };

    while (!reader.done) {
        long total = compute_calories_for_elf(&reader);
        if (total == -1) {
            return -1;
        }
        MaxArray_add_value(maximums, total);
    }
    long sum = 0;
    for (size_t i = 0; i < maximums->size; i++) {
        sum += maximums->values[i];
    }
    free(maximums);

    return sum;
}

int main(int argc, const char** argv) {
    if (argc < 2) {
        fprintf(stderr, "Provide input file\n");
        return 1;
    }
    const char* filename = argv[1];

    FILE* file = fopen(filename, "r");
    if (!file) {
        perror("Failed to open file");
        return 1;
    }

    printf("day 1: %ld\n", day1(file));

    // reset file
    fseek(file, 0, SEEK_SET);
    printf("day 2: %ld\n", day2(file));
    return 0;
}
