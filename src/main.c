/*
*   Aurora Demo
*   CS 77 - 17F
*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

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

#define INFOLOG_LEN 1024

bool load_shaders (GLuint * const program);
void render ();
void drag_camera (int x, int y);
static int screenWidth, screenHeight;
static GLuint frameTexture, accumulateTexture, framebuffer, frameCountUniform;

int main (int argc, char* argv[]) {
    // Parse input
    if (argc < 3) {
        fprintf(stderr, "Error: Invalid argument count\n");
        return EXIT_FAILURE;
    }
    screenWidth = atoi(argv[1]);
    screenHeight = atoi(argv[2]);
    // Setup GLUT window
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);
    glutInitWindowSize(screenWidth, screenHeight);
    glutCreateWindow("Aurora Demo");
    glutDisplayFunc(render);
    glutIdleFunc(render);
    glutMotionFunc(drag_camera);
    glViewport(0,0, screenWidth, screenHeight);
    GLuint program; // This gets leaked :(
    if (!load_shaders(&program)) return EXIT_FAILURE;
    // Setup FBO
    glGenTextures(1, &accumulateTexture);
    glBindTexture(GL_TEXTURE_2D, accumulateTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, screenWidth, screenHeight, 0, GL_RGBA, GL_FLOAT, NULL);
    glGenTextures(1, &frameTexture);
    glBindTexture(GL_TEXTURE_2D, frameTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, screenWidth, screenHeight, 0, GL_RGBA, GL_FLOAT, NULL);    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frameTexture, 0);
    const GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (GL_FRAMEBUFFER_COMPLETE != status) fprintf(stderr, "Error: Failed to prepare framebuffer\n");
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    // Start running
    glUseProgram(program);
    frameCountUniform = glGetUniformLocation(program, "frameCount");
    glUniform1i(glGetUniformLocation(program, "accumulateTexture"), 0);
    glUniform2f(glGetUniformLocation(program, "WindowSize"), screenWidth, screenHeight); // Set window size
    glMatrixMode(GL_MODELVIEW);
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_ONE);
    glutMainLoop(); // Blocks on render loop
    return EXIT_SUCCESS;
}

void render () {
    static int frame = 0;
    glUniform1f(frameCountUniform, frame++);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, accumulateTexture);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, framebuffer);
    glLoadIdentity();
    // Draw a quad
    glBegin(GL_QUADS);
    glTexCoord2f(0.f, 0.f);
    glVertex3f(-1.f, -1.f, -1.f);
    glTexCoord2f(1.f, 0.f);
    glVertex3f(1.f, -1.f, -1.f);
    glTexCoord2f(1.f, 1.f);
    glVertex3f(1.f, 1.f, -1.f);
    glTexCoord2f(0.f, 1.f);
    glVertex3f(-1.f, 1.f, -1.f);
    glEnd();
    // Blit to screen and update accumulate texture
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, framebuffer);
    glBlitFramebuffer(0, 0, screenWidth, screenHeight, 0, 0, screenWidth, screenHeight, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    glReadBuffer(GL_COLOR_ATTACHMENT0);
    glCopyTexSubImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, screenWidth, screenHeight, 0);
    // Post
    glutSwapBuffers();
}

void drag_camera (int x, int y) { // NOTE: Y is inverted (0 is top, not bottom)
    // Orbit camera around scene
    printf("mouse drag at (%i %i)\n", x, y);
}

bool load_shaders (GLuint * const program) {
    // Load vertex and fragment sources
    FILE *file = fopen("src/vert.glsl", "r");
    if (!file) {
        fprintf(stderr, "Error: Failed to open vertex source\n");
        return false;
    }
    fseek(file, 0L, SEEK_END);
    size_t size = ftell(file);
    const GLchar* vertexSource = calloc(sizeof(char), size);
    rewind(file);
    fread((void*)vertexSource, size, sizeof(char), file);
    fclose(file);
    file = fopen("src/frag.glsl", "r");
    if (!file) {
        fprintf(stderr, "Error: Failed to open fragment source\n");
        return false;
    }
    fseek(file, 0L, SEEK_END);
    size = ftell(file);
    const GLchar* fragmentSource = calloc(sizeof(char), size);
    rewind(file);
    fread((void*)fragmentSource, size, sizeof(char), file);
    fclose(file);
    // Create vertex shader
    GLint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, &vertexSource, NULL);
    glCompileShader(vertexShader);
    GLint success; char infoLog[INFOLOG_LEN];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertexShader, INFOLOG_LEN, NULL, infoLog);
        glDeleteShader(vertexShader);
        fprintf(stderr, "Error: Failed to compile vertex shader with error: %s\n", infoLog);
        return false;
    }
    // Fragment shader
    GLint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader, 1, &fragmentSource, NULL);
    glCompileShader(fragmentShader);
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fragmentShader, INFOLOG_LEN, NULL, infoLog);
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        fprintf(stderr, "Error: Failed to compile fragment shader with error: %s\n", infoLog);
        return false;
    }
    // Link shaders
    GLuint shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if (!success) {
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        glGetShaderInfoLog(shaderProgram, INFOLOG_LEN, NULL, infoLog);
        fprintf(stderr, "Error: Failed to link shader with error: %s\n", infoLog);
        return false;
    }
    glDetachShader(shaderProgram, vertexShader);
    glDetachShader(shaderProgram, fragmentShader);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    *program = shaderProgram;
    return true;
}
