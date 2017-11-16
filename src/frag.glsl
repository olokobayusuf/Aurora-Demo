/*
*   Aurora Demo
*   CS 77 - 17F
*/

varying vec2 uv;

struct Ray {
    vec3 origin;
    vec3 direction;
    vec2 range;
};

struct Sphere {
    vec3 position;
    float radius;
};

void main () {
    /*
    * This maps to `Scene::raytrace` in DIRT. From here, we want to generate a ray from `uv` and call `radiance`
    */

    // Set the color
    gl_FragColor = vec4(uv.x, 0.0, uv.y, 1.0);
}

void radiance (const Ray ray) {
    /*
    * Intersect the ray with the entire scene (call `intersect`) and save the closest intersection
    * If there was no intersection, return the background color
    * If not, call `shade`
    */
}

void shade (const Ray ray) {
    /*
    * Calculate the color and return it
    */
}

void intersect (inout Ray ray, const Sphere sphere) {

}
