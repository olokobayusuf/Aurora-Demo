/*
*   Aurora Demo
*   CS 77 - 17F
*/

varying vec2 uv;

void main () {
    // We don't care about position
    gl_Position = ftransform();
    // Assign the UV coordinate (ray direction)
    uv = vec2(gl_MultiTexCoord0);
}