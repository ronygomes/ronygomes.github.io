#include <stdio.h>
#include <greet.h>

void printGreetings(int n) {
    for (int i = 0; i < n; i++) {
        printDecorated("Hello");
    }
}
