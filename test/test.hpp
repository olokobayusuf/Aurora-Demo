#include <iostream>

using namespace std;

typedef unsigned (*TestCase) ();

#pragma mark --Test Cases--


// Define test cases to run
static TestCase tests[] = {

};

#define TEST_COUNT (sizeof(tests) / sizeof(TestCase))
