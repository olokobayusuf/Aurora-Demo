/*
*   Aurora Demo
*   CS 77 - 17F
*/

#pragma once

#include <stdio>
#include <stdlib>

typedef int (*TestCase) ();

#pragma mark --Test Cases--


// Define test cases to run
static TestCase tests[] = {

};

#define TEST_COUNT (sizeof(tests) / sizeof(TestCase))
