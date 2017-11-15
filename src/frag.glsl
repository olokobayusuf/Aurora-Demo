/*
*   Aurora Demo
*   CS 77 - 17F
*/

varying vec2 uv;

void main () {
    // Set the color
    gl_FragColor = vec4(uv.x, 0.0, uv.y, 1.0);
}
