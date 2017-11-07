/*
*   Aurora Demo
*   CS 77 - 17F
*/

#include "test.h"

int main (int argc, char* argv[]) {
    // Run tests
    for (unsigned i = 0; i < TEST_COUNT; i++) if (tests[i]()) return EXIT_FAILURE;
    // Tests succeeded
    return EXIT_SUCCESS;
}