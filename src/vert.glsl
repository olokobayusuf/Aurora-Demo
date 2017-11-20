/*
*   Aurora Demo
*   CS 77 - 17F
*/

attribute vec2 a_position;
attribute vec2 a_texcoord;
varying vec2 uv;

void main () {
    // We don't care about position
    gl_Position = vec4(a_position, 0.0, 1.0);
    // Assign the UV coordinate (ray direction)
    uv = a_texcoord;
}