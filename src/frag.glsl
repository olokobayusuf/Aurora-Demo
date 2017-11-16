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

#define M_PI 3.1415926535897932384626433832795
#define SCENE_SIZE 2
#define IMAGE_SAMPLES 2.0

const Sphere scene[SCENE_SIZE] = Sphere[] (
    Sphere(
        vec3(0.0, 0.0, 5.0),
        1.0
    ),
    Sphere(
        vec3(2.0, -1.0, 6.0),
        1.0
    )
);
#pragma endregion


#pragma region --Top level--

vec3 radiance (Ray ray);
vec3 shade (const Ray ray);
bool intersect (inout Ray ray, const Sphere sphere);
Ray generateRay (const vec2 uv, const Camera camera);

uniform vec2 WindowSize;
varying vec2 uv;

/**
* Raytrace for each `uv` position on screen.
* We generate a way for the `uv` position and accumulate its radiance
*/
void main () {
    // Create a camera
    Camera camera = Camera(mat4(1.0), 60);
    // Get the texel size
    vec2 texelSize = vec2(1.0 / WindowSize.x, 1.0 / WindowSize.y) / IMAGE_SAMPLES;
    vec3 color = vec3(0.0);
    for (int y = 0; y < IMAGE_SAMPLES; y++) for (int x = 0; x < IMAGE_SAMPLES; x++) {
        // Calculate the sub-uv coordinates
        vec2 sample_uv = uv + dot(texelSize, vec2(x, y)) - 0.5 * IMAGE_SAMPLES * texelSize;
        // Create a ray from the `uv` coordinates
        Ray ray = generateRay(sample_uv, camera);
        // Accumulate color
        color += radiance(ray);
    }
    // Set the color
    gl_FragColor = vec4(color / IMAGE_SAMPLES / IMAGE_SAMPLES, 1.0);
}

/**
* Intersect the ray with the entire scene (call `intersect`) and save the closest intersection.
* If there was no intersection, return the background color.
* If there was, call `shade` and return the color.
*/
vec3 radiance (Ray ray) {
    for (int i = 0; i < SCENE_SIZE; i++) if (intersect(ray, scene[i])) ray.range.y = ray.intersectionPoint;
    // Check if we hit something and return the shading color
    if (ray.intersectionPoint > 0) return shade(ray);
    // No intersection, so return background color
    return vec3(0.1);
}

/**
* Calculate the color for a ray and return it.
*/
vec3 shade (const Ray ray) { // INCOMPLETE
    return -ray.intersectionNormal * 0.5 + vec3(0.5);
}
#pragma endregion


#pragma region --Calculations--

/**
* Ray-sphere intersection.
*/
bool intersect (inout Ray ray, const Sphere sphere) {
    vec3 o = ray.origin;
    vec3 d = normalize(ray.direction);
    vec3 c = sphere.position;
    float r = sphere.radius;
    float rr = r * r;
    float co_norm_sqr = dot(c - o, c - o);
    float co_proj_d = dot(d, c - o);
    // Check that the sphere isn't behind us
    if (co_proj_d < 0) return false;
    float proj_sphere_sqr = co_norm_sqr - co_proj_d * co_proj_d;
    // Check that closest point on ray to sphere origin is less than or equal to sphere radius
    if (proj_sphere_sqr > rr) return false;
    // Get half chord distance
    float half_chord = sqrt(rr - proj_sphere_sqr);
    // Calculate t and intersection point
    float t = co_proj_d - half_chord;
    vec3 its = o + d * t;
    // Check that we're in range
    if (t < ray.range.x ||  t > ray.range.y) return false;
    // Set ray params
    ray.intersectionPoint = t;
    ray.intersectionNormal = normalize(its - c);
    return true;
}

Ray generateRay (const vec2 uv, const Camera camera) {
    float planeZ = 0.5 / tan(camera.fov * M_PI / 360.0);
    vec3 position = camera.transform[3].xyz;
    vec3 planePoint = vec3((uv.x - 0.5) * WindowSize.x / WindowSize.y, uv.y - 0.5, planeZ);    
    vec4 worldPoint = camera.transform * vec4(planePoint, 1.0);
    vec3 direction = worldPoint.xyz - position;
    return Ray(position, direction, vec2(1e-5, 1e+5), 0, vec3(0.0));
}
#pragma endregion
