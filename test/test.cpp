/*
*   Tests
*   
*/

#pragma mark --Application Entry Point--

int main (int argc, char* argv[]) {
    // Run tests
    for (unsigned i = 0; i < TEST_COUNT; i++) if (tests[i]()) return FAILURE;
    // Tests succeeded
    return SUCCESS;
}