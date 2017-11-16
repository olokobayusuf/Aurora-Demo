/*
*   Aurora Demo
*   CS 77 - 17F
*/

#version 120

#pragma region --Types and constants--

struct Ray {
    vec3 origin;
    vec3 direction;
    vec2 range;
};

struct Sphere {
    vec3 position;
    float radius;
};

const Sphere scene[2] = Sphere[] (
    Sphere(
        vec3(0.0, 0.0, 0.0),
        4.0
    ),
    Sphere(
        vec3(1.0, 2.0, 2.0),
        4.0
    )
);
#pragma endregion


#pragma region --Top level--

varying vec2 uv;

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
#pragma endregion


#pragma region --Calculations--

void intersect (inout Ray ray, const Sphere sphere) {

}

Ray generate_ray (const vec2 uv) {
    return Ray(vec3(0.0), vec3(0.0), vec2(1e-5, 1e+5));
}
#pragma endregion
