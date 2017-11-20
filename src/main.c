/*
*   Aurora Demo
*   CS 77 - 17F
*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <math.h>

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

#define INFOLOG_SIZE 1024

bool load_shaders (GLuint * const program);
void render ();
void drag_camera (int x, int y);

static int screenWidth, screenHeight;
static GLuint dataBuffer[2], frameTextures[2], framebuffer, frameCountUniform, cameraPositionUniform;
static GLint positionAttribute, uvAttribute, accumulateUniform;
static int fboAttachment;

static float vertexData[] = {
    -1.0f,  -1.0f,  // Position 0
    1.0f,  -1.0f,   // Position 1
    -1.0f,   1.0f,  // Position 2
    1.0f,   1.0f    // Position 3
}, textureData[] = {
    0.0f,   0.0f,   // TexCoord 0
    1.0f,   0.0f,   // TexCoord 1
    0.0f,   1.0f,   // TexCoord 2
    1.0f,   1.0f    // TexCoord 3
};

const int camRadius = 18;
static float camPos[3] = {0, 0, -camRadius};
static int prevPos[2];

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
    // Load program
    GLuint program; // This gets leaked :(
    if (!load_shaders(&program)) return EXIT_FAILURE;
    // Setup FBO
    glGenTextures(2, frameTextures);
    for (int i = 0; i < 2; i++) {
        glBindTexture(GL_TEXTURE_2D, frameTextures[i]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F_ARB, screenWidth, screenHeight, 0, GL_RGBA, GL_FLOAT, NULL);
    }
    glGenFramebuffers(1, &framebuffer);
    // Generate drawing resources
    glGenBuffers(2, dataBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, dataBuffer[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof vertexData * 4, vertexData, GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, dataBuffer[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof textureData * 4, textureData, GL_STATIC_DRAW);
    // Start running
    glUseProgram(program);
    cameraPositionUniform = glGetUniformLocation(program, "cameraPosition");
    frameCountUniform = glGetUniformLocation(program, "frameCount");
    glUniform1i(glGetUniformLocation(program, "accumulateTexture"), 0);
    glUniform2f(glGetUniformLocation(program, "WindowSize"), screenWidth, screenHeight); // Set window size
    glUniform3f(cameraPositionUniform, camPos[0], camPos[1], camPos[2]);
    glMatrixMode(GL_MODELVIEW);
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_ONE);
    glutMainLoop(); // Blocks on render loop
    return EXIT_SUCCESS;
}

void render () {
    static int frame = 0;
    glUniform1f(frameCountUniform, frame++);
    // Bind FBO and accumulate texture
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, framebuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, frameTextures[fboAttachment], 0);
    fboAttachment = (int)!fboAttachment;
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, frameTextures[fboAttachment]);
    glUniform1i(accumulateUniform, 0);
    // Draw a quad
    glBindBuffer(GL_ARRAY_BUFFER, dataBuffer[0]);
    glEnableVertexAttribArray(positionAttribute);
    glVertexAttribPointer(positionAttribute, 2, GL_FLOAT, false, 0, 0);
    glBindBuffer(GL_ARRAY_BUFFER, dataBuffer[1]);
    glEnableVertexAttribArray(uvAttribute);
    glVertexAttribPointer(uvAttribute, 2, GL_FLOAT, false, 0, 0);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    // Blit to screen
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
    glBindFramebuffer(GL_READ_FRAMEBUFFER, framebuffer);
    glBlitFramebuffer(0, 0, screenWidth, screenHeight, 0, 0, screenWidth, screenHeight, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    // Post
    glutSwapBuffers();
}

void drag_camera (int x, int y) { // NOTE: Y is inverted (0 is top, not bottom)
    // Orbit camera around scene
    if (prevPos[0] == 0) {
        prevPos[0] = x;
        prevPos[1] = y;
    }
    float deltaPos[2];
    deltaPos[0] = x - prevPos[0]; deltaPos[1] = y - prevPos[1];

    double horizontal_angle = deltaPos[0] / camRadius;
    camPos[0] = camPos[0] + camRadius * sin(horizontal_angle);
    camPos[2] = camPos[2] + camRadius - camRadius * cos(horizontal_angle);

    double vertical_angle = deltaPos[1] / camRadius;
    camPos[1] = camPos[1] + camRadius * sin(vertical_angle);
    
    prevPos[0] = x; prevPos[1] = y;
    glUniform3f(cameraPositionUniform, camPos[0], camPos[1], camPos[2]);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER, framebuffer);
    glClearColor(0.f, 0.f, 0.f, 0.f);
    glClear(GL_COLOR_BUFFER_BIT);
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
    GLint success; char infoLog[INFOLOG_SIZE];
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertexShader, INFOLOG_SIZE, NULL, infoLog);
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
        glGetShaderInfoLog(fragmentShader, INFOLOG_SIZE, NULL, infoLog);
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
        glGetShaderInfoLog(shaderProgram, INFOLOG_SIZE, NULL, infoLog);
        fprintf(stderr, "Error: Failed to link shader with error: %s\n", infoLog);
        return false;
    }
    glDetachShader(shaderProgram, vertexShader);
    glDetachShader(shaderProgram, fragmentShader);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    *program = shaderProgram;
    // Get attributes and uniforms
    glUseProgram(shaderProgram);
    positionAttribute = glGetAttribLocation(shaderProgram, "a_position");
    uvAttribute = glGetAttribLocation(shaderProgram, "a_texcoord");
    frameCountUniform = glGetUniformLocation(shaderProgram, "frameCount");
    accumulateUniform = glGetUniformLocation(shaderProgram, "accumulateTexture");
    glUniform2f(glGetUniformLocation(shaderProgram, "WindowSize"), screenWidth, screenHeight); // Set window size
    return true;
}
