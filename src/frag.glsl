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
    float intersectionPoint;
    vec3 intersectionNormal;
};

struct Sphere {
    vec3 position;
    float radius;
};

struct Camera {
    mat4 transform;
    float fov;
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

vec3 radiance (const Ray ray);
varying vec2 uv;

/**
* Raytrace for each `uv` position on screen.
* We generate a way for the `uv` position and accumulate its radiance
*/
void main () {
    // Create a ray from the `uv` coordinates
    vec3 position = vec3(0.0, 0.0, -5.0);
    vec3 planePoint = vec3(uv.x - 0.5, uv.y - 0.5, -2.0);
    vec3 direction = planePoint - position;
    Ray ray = Ray(position, direction, vec2(1e-5, 1e+5), 0, vec3(0.0));
    // Set the color
    gl_FragColor = vec4(radiance(ray), 1.0);
}

/**
* Intersect the ray with the entire scene (call `intersect`) and save the closest intersection.
* If there was no intersection, return the background color.
* If there was, call `shade` and return the color.
*/
vec3 radiance (const Ray ray) { // INCOMPLETE
    return normalize(vec3(ray.direction.x, ray.direction.y, 0.0));
}

/**
* Calculate the color for a ray and return it.
*/
vec3 shade (const Ray ray) { // INCOMPLETE
    return vec3(0.0);
}
#pragma endregion


#pragma region --Calculations--

/**
* Ray-sphere intersection.
*/
bool intersect (inout Ray ray, const Sphere sphere) { // INCOMPLETE
    return false;
}
#pragma endregion
