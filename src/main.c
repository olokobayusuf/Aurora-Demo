/*
*   Aurora Demo
*   CS 77 - 17F
*/

#include <stdio.h>
#include <stdlib.h>
#ifdef __APPLE__
    #include <GLUT/glut.h>
    #include <OpenGL/gl.h>
    #include <OpenGL/glu.h>
#else
    #ifdef _WIN32
        #include <windows.h>
    #endif
    #include <GL/gl.h>
    #include <GL/glu.h>
    #include <GL/glut.h>
#endif

void render ();
void drag_camera (int x, int y);

int main (int argc, char* argv[]) {
    // Parse input
    if (argc < 3) {
        fprintf(stderr, "Error: Invalid argument count\n");
        return EXIT_FAILURE;
    }
    int screenWidth = atoi(argv[1]);
    int screenHeight = atoi(argv[2]);
    // Setup GLUT window
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
    glutInitWindowSize(screenWidth, screenHeight);
    glutCreateWindow("Aurora Demo");
    glutDisplayFunc(render);
    glutMotionFunc(drag_camera);
    glViewport(0,0, screenWidth, screenHeight);
    glutMainLoop(); // Blocks on render loop
    return EXIT_SUCCESS;
}

void render () {
    // Clear to black
    // Draw a fullscreen quad (use immediate mode functions, glBegin/glEnd)
    // Swap buffers

    glClearColor(1.f, 0.1f, 0.2f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    glutSwapBuffers();
}

void drag_camera (int x, int y) { // NOTE: Y is inverted (0 is top, not bottom)
    // Orbit camera around scene
    printf("mouse drag at (%i %i)\n", x, y);
}
