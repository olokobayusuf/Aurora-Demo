# Aurora Demo - Coding Standards
Below is a nonexhaustive list of coding standards for this project:

## Top Level
- The project's sources will be written in `C`.
- We will be using the C11 standard.
- Due to the small size of the project, we will be using Makefile for building.
- The project has a simple directory structure:
    - `src` will contain sources and (local) headers.
    - `lib` will contain static and shared libraries that are used for building (referenced by the Makefile).
    - `include` will contain global headers (for libraries for instance).
    - `bin` will contain final executables
    - `build` will contain compiled object files during compilation. This directory will **not** be included in source control (as defined by `.gitignore`).
    - `test` will contain a test sub-project. More on testing below.

## Sources
- All headers and source files will begin with the project name:
```c
/*
*   Aurora Demo
*   CS 77 - 17F
*/
```
- All headers that will be included in multiple source files will use the `#pragma once` directive as opposed to the `#ifndef __HEADER` directives.
- All macros and constants must be in all caps, for example `#define MAX(a, b) ...`.
- Struct names and typedefs must be in camel case, for example `struct Person {...}`.
- **Variable should have unambiguous names**. This is absolutely crucial. We prefer clarity over brevity.
- There will be no `typedef struct ...`'s. This is somewhat contentious, but for clarity, we want to know that every struct that is declared is a struct.
- Function names will be in snake case, for example `void get_person_age (struct Person* person);`
- We will indent using 4 spaces.
- Comments! Basically, we don't want comments before every line of code, but we want comments that can explain the overall flow of logic through the program.
- Minimize empty lines in functions.

## Tests
*INCOMPLETE*