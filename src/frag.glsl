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

#define SCENE_SIZE 2

const Sphere scene[SCENE_SIZE] = Sphere[] (
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

vec3 radiance (Ray ray);
vec3 shade (const Ray ray);
bool intersect (inout Ray ray, const Sphere sphere);
Ray generateRay (const vec2 uv, const Camera camera);
varying vec2 uv;

/**
* Raytrace for each `uv` position on screen.
* We generate a way for the `uv` position and accumulate its radiance
*/
void main () {
    // Create a camera
    Camera camera = Camera(mat4(1.0), 2.0);
    camera.transform[3] = vec4(0.0, 0.0, -5.0, 1.0);
    // Create a ray from the `uv` coordinates
    Ray ray = generateRay(uv, camera);
    // Set the color
    gl_FragColor = vec4(radiance(ray), 1.0);
}

/**
* Intersect the ray with the entire scene (call `intersect`) and save the closest intersection.
* If there was no intersection, return the background color.
* If there was, call `shade` and return the color.
*/
vec3 radiance (Ray ray) { // INCOMPLETE
    vec3 color = vec3(0.0);
    for (int i = 0; i < SCENE_SIZE; i++) {
        Sphere sphere = scene[i];
        if (intersect(ray, sphere)) {
            color = vec3(1.0);
            break;
        }
    }
    return color;
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
    d= normalize(d);
    vec3 c = sphere.position;
    float r = sphere.radius;
    float cdistance = sqrt((c[0] - o[0])*(c[0] - o[0]) + (c[1] - o[1])*(c[1] - o[1]) + (c[2] - o[2])*(c[2] - o[2]));
    float codistance = d[0]*(c[0] - o[0]) + d[1]*(c[1]- o[1]) + d[2]*(c[2] - o[2]);
    if (codistance < 0) {
        return false;
    }
    float shortdistance = cdistance*cdistance - codistance*codistance;
    if (shortdistance > r * r) {
        return false;
    }

    float linedistance = sqrt(r*r - shortdistance);
    float t = codistance - linedistance;
    ray.intersectionPoint = t;
    vec3 its;
    its[0] = o[0] + d[0] * t;
    its[1] = o[1] + d[1] * t;
    its[2] = o[2] + d[2] * t;

    if (t < ray.range[0] ||  t > ray.range[1]) {
        return false;
    }

    ray.intersectionNormal[0] = its[0] - c[0];
    ray.intersectionNormal[1] = its[1] - c[1];
    ray.intersectionNormal[2] = its[2] - c[2];
    ray.intersectionNormal = normalize(ray.intersectionNormal);

    return true;
}

Ray generateRay (const vec2 uv, const Camera camera) { // INCOMPLETE
    vec3 position = camera.transform[3].xyz;
    vec3 planePoint = vec3(uv.x - 0.5, uv.y - 0.5, -camera.fov);
    vec3 direction = planePoint - position;
    return Ray(position, direction, vec2(1e-5, 1e+5), 0, vec3(0.0));
}
#pragma endregion
