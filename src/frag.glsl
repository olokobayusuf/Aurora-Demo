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

vec3 radiance (const Ray ray);
varying vec2 uv;

/**
* Raytrace for each `uv` position on screen.
* We generate a way for the `uv` position and accumulate its radiance
*/
void main () {
    // Create a ray from the `uv` coordinates
    Ray ray = Ray(vec3(0.0), vec3(0.0), vec2(1e-5, 1e+5));
    // Set the color
    gl_FragColor = vec4(radiance(ray), 1.0);
}

/**
* Intersect the ray with the entire scene (call `intersect`) and save the closest intersection.
* If there was no intersection, return the background color.
* If there was, call `shade` and return the color.
*/
vec3 radiance (const Ray ray) { // INCOMPLETE
    return vec3(0.0);
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
    vec3 o = ray.origin;
    vec3 d = ray.direction;
    d= d.normalize();
    vec3 c = sphere.position;
    float r = sphere.radius;
    float cdistance = sqrt((c(0) - o(0))*(c(0) - o(0)) + (c(1) - o(1))*(c(1) - o(1)) + (c(2) - o(2))*(c(2) - o(2)));
    float codistance = d(0)*(c(0) - o(0)) + d(1)*(c(1) - o(1)) + d(2)*(c(2) - o(2));
    if (codistance < 0) {
        return false;
    }
    float shortdistance = cdistance*cdistance - codistance*codistance;
    if (shortdistance > r * r) {
        return false;
    }

    float linedistance = sqrt(r*r - shortdistance);
    float t = codistance - linedistance;

    return false;
}
#pragma endregion
