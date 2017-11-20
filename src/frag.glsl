/*
*   Aurora Demo
*   CS 77 - 17F
*/

#version 120

#define INDIRECT_LIGHTING

#define IMAGE_SAMPLES 2
#define LIGHT_BOUNCES 5
#define SCENE_SIZE 10
#define WALL_RADIUS 1e+5f
#define WALL_OFFSET 8.0
#define DEFAULT_RANGE vec2(1e-5, 1e+5)
#define M_PI 3.1415926535897932384626433832795

#pragma region --Types and constants--

struct Ray {
    vec3 origin, direction;
    vec2 range;
    float intersectionPoint;
    vec3 intersectionNormal;
    int intersectionMaterial;
};

struct Sphere {
    vec3 position;
    float radius;
    int material; // Index into `material` array
};

struct Camera {
    mat4 transform;
    float fov;
};

struct Light {
    vec3 position, color;
};

struct Material {
    vec3 color, emission;
};

const Sphere scene[SCENE_SIZE] = Sphere[] (
    // Scene
    Sphere(
        vec3(4.0, -WALL_OFFSET + 2.0, -3.0),
        2.0,
        4
    ),
    Sphere(
        vec3(-2.0, -WALL_OFFSET + 2.0, 2.0),
        2.0,
        4
    ),
    Sphere(
        vec3(2.0, 0.0, 4.0),
        2.5,
        4
    ),
    Sphere(
        vec3(-2.0, 2.0, 1.0),
        2.5,
        4
    ),
    // Light
    Sphere(vec3(0.0, WALL_OFFSET, -3.0), 1.0, 0),
    // Walls
    Sphere(vec3(-WALL_RADIUS - WALL_OFFSET, 0.0, 0.0), WALL_RADIUS, 1),         // Left wall
    Sphere(vec3(WALL_RADIUS + WALL_OFFSET, 0.0, 0.0), WALL_RADIUS, 2),          // Right wall
    Sphere(vec3(0.0, 0.0, WALL_RADIUS + WALL_OFFSET + 3.0), WALL_RADIUS, 3),    // Front wall
    Sphere(vec3(0.0, -WALL_RADIUS - WALL_OFFSET, 0.0), WALL_RADIUS, 3),         // Floor
    Sphere(vec3(0.0, WALL_RADIUS + WALL_OFFSET, 0.0), WALL_RADIUS, 3)           // Ceiling
);

const Light lights[1] = Light[] (
    Light(vec3(0.0, WALL_OFFSET, 0.0), vec3(150.0))
);

const Material materials[5] = Material[] (
    Material(vec3(1.0), vec3(2.0)),             // White light
    Material(vec3(0.7, 0.2, 0.1), vec3(0.0)),   // Reddish
    Material(vec3(0.1, 0.3, 0.6), vec3(0.0)),   // Blueish
    Material(vec3(0.4), vec3(0.0)),             // Gray
    Material(vec3(0.8), vec3(0.0))              // Light gray
);
#pragma endregion


#pragma region --Top level--

vec3 radiance (Ray ray);
bool intersect_scene (inout Ray ray);
bool intersect_sphere (inout Ray ray, const Sphere sphere);
Ray generate_ray (const vec2 uv, const Camera camera);
vec3 generate_hemisphere_point (float random1, float random2);
float rand (vec2 seed);

uniform sampler2D accumulateTexture;
uniform vec2 WindowSize;
uniform float frameCount;
varying vec2 uv;

/**
* Raytrace for each `uv` position on screen.
* We generate a way for the `uv` position and accumulate its radiance
*/
void main () {
    // Create a camera
    mat4 camTransform = mat4(1.0);
    camTransform[3] = vec4(0.0, 0.0, -18.0, 1.0);
    Camera camera = Camera(camTransform, 60);
    // Get the texel size
    vec2 texelSize = vec2(1.0 / WindowSize.x, 1.0 / WindowSize.y) / IMAGE_SAMPLES;
    vec3 color = vec3(0.0);
    for (int y = 0; y < IMAGE_SAMPLES; y++) for (int x = 0; x < IMAGE_SAMPLES; x++) {
        // Calculate the sub-uv coordinates
        vec2 sample_uv = uv + dot(texelSize, vec2(x, y)) - 0.5 * IMAGE_SAMPLES * texelSize;
        // Create a ray from the `uv` coordinates
        Ray ray = generate_ray(sample_uv, camera);
        // Accumulate color
        color += radiance(ray);
    }
    // Normalize and blend with accumulation texture
    color /= IMAGE_SAMPLES * IMAGE_SAMPLES;
    vec3 accumulatedColor = texture2D(accumulateTexture, uv).rgb;
    #ifdef INDIRECT_LIGHTING
    color = max(color, accumulatedColor);
    #else
    color = mix(color, accumulatedColor, frameCount / (frameCount + 1.0));
    #endif
    // Set the color
    gl_FragColor = vec4(color, 1.0);
}

/**
* Calculate the color for a ray and return it.
*/
vec3 radiance (Ray ray) { // INCOMPLETE
    vec3 accumulant = vec3(0.0);
    vec3 colorMask = vec3(1.0);
    for (int bounce = 0; bounce < LIGHT_BOUNCES; bounce++) {
        // Check if the ray intersects with the scene
        if (!intersect_scene(ray)) break;
        #ifdef INDIRECT_LIGHTING
        // Calculate shading point
        vec3 shadingPoint = ray.origin + ray.direction * ray.intersectionPoint;
        Material material = materials[ray.intersectionMaterial];
        // Add emmision
        accumulant += material.emission * colorMask;
        // Calculate an orthonormal frame at the shading point
        // We use this frame to orient our random point on the unit hemisphere
        vec3 w = ray.intersectionNormal, u = vec3(0.0), v = vec3(0.0);
        if (abs(w.y) > 0.95) { // Pretty hacky
            float dir = sign(-w.y);
            v = dir * vec3(0.0, 1.0, 0.0);
            w = vec3(0.0, 0.0, 1.0);
            u = vec3(1.0, 0.0, 0.0);
        } else {
            u = normalize(cross(vec3(0.0, 1.0, 0.0), w));
            v = cross(w, u);
        }
        mat3 normalFrame = mat3(u, v, w);
        // Calculate a random ray direction on the unit hemisphere for light to bounce in
        vec3 hemispherePoint = generate_hemisphere_point(M_PI * rand(uv + vec2(0.323, -0.653434)), M_PI * rand(uv + vec2(-0.882, 0.63473)));
        ray.origin = shadingPoint + ray.intersectionNormal * 0.0001;
        ray.direction = normalize(normalFrame * hemispherePoint);
        ray.range = DEFAULT_RANGE; // Don't forget to reset the range
        // Update the mask color
        colorMask *= material.color * dot(-ray.direction, ray.intersectionNormal);
        #else
        // Calculate shading point
        vec3 shadingPoint = ray.origin + ray.direction * ray.intersectionPoint;
        Material material = materials[ray.intersectionMaterial];
        colorMask *= material.color;// * dot(-ray.direction, ray.intersectionNormal);
        // Compute diffuse lighting
        for (int l = 0; l < 1; l++) {
            // Calcualte light direction
            Light light = lights[l];
            vec3
            lightDirection = light.position - shadingPoint,
            lightIntensity = light.color / dot(lightDirection, lightDirection);
            lightDirection = normalize(lightDirection);
            // Check for shadow
            Ray shadowRay = Ray(shadingPoint, lightDirection, vec2(0.05, length(light.position - shadingPoint) - 0.1), 0, vec3(0.0), -1);
            if (intersect_scene(shadowRay)) continue;
            // Compute light response
            accumulant += colorMask * lightIntensity * max(dot(-lightDirection, ray.intersectionNormal), 0.0);
        }
        // Calculate an orthonormal frame at the shading point
        // We use this frame to orient our random point on the unit hemisphere
        vec3
        w = ray.intersectionNormal,
        u = normalize(cross(vec3(0.0, 1.0, 0.0), w)),
        v = cross(w, u);
        mat3 normalFrame = mat3(u, v, w);
        // Calculate a random ray direction on the unit hemisphere for light to bounce in
        vec3 hemispherePoint = generate_hemisphere_point(M_PI * rand(uv + vec2(0.323, -0.653434)), M_PI * rand(uv + vec2(-0.882, 0.63473)));
        ray.origin = shadingPoint + ray.intersectionNormal * 0.0001;
        ray.direction = normalize(normalFrame * hemispherePoint);
        ray.range = DEFAULT_RANGE; // Don't forget to reset the range
        #endif
    }
    return accumulant;
}
#pragma endregion


#pragma region --Calculations--

/**
* Intersect the ray with the entire scene (call `intersect`) and save the closest intersection.
* If there was no intersection, return false.
*/
bool intersect_scene (inout Ray ray) {
    // Intersect all objects in the scene
    for (int i = 0; i < SCENE_SIZE; i++) if (intersect_sphere(ray, scene[i])) {
        ray.range.y = ray.intersectionPoint;
        ray.intersectionMaterial = scene[i].material;
    }
    return ray.intersectionPoint > 0;
}

/**
* Ray-sphere intersection.
*/
bool intersect_sphere (inout Ray ray, const Sphere sphere) {
    float sqrRadius = sphere.radius * sphere.radius;
    float co_proj_d = dot(ray.direction, sphere.position - ray.origin);
    // Check that the sphere isn't behind us
    if (co_proj_d < 0) return false;
    float proj_sphere_sqr = dot(sphere.position - ray.origin, sphere.position - ray.origin) - co_proj_d * co_proj_d;
    // Check that closest point on ray to sphere origin is less than or equal to sphere radius
    if (proj_sphere_sqr > sqrRadius) return false;
    // Get half chord distance
    float half_chord = sqrt(sqrRadius - proj_sphere_sqr);
    // Calculate t and intersection point
    float t = co_proj_d - half_chord;
    vec3 its = ray.origin + ray.direction * t;
    // Check that we're in range
    if (t < ray.range.x ||  t > ray.range.y) return false;
    // Set ray params
    ray.intersectionPoint = t;
    ray.intersectionNormal = (sphere.position - its) / sphere.radius;
    return true;
}

/**
* Generate a ray from the `uv` camera plane position
*/
Ray generate_ray (const vec2 uv, const Camera camera) {
    float planeZ = 0.5 / tan(camera.fov * M_PI / 360.0);
    vec3 position = camera.transform[3].xyz;
    vec3 planePoint = vec3((uv.x - 0.5) * WindowSize.x / WindowSize.y, uv.y - 0.5, planeZ);    
    vec4 worldPoint = camera.transform * vec4(planePoint, 1.0);
    vec3 direction = normalize(worldPoint.xyz - position);
    return Ray(position, direction, DEFAULT_RANGE, -1, vec3(0.0), -1);
}

vec3 generate_hemisphere_point (float random1, float random2) {
    return vec3(
        cos(random1) * cos(random2),
        sin(random1),
        sin(random2) * cos(random1)
    );
}

/**
* Pseudo-random number generator.
* Source: https://stackoverflow.com/questions/4200224/random-noise-functions-for-glsl
*/
float rand (vec2 seed) {
    // TODO: Add uv.x * some random constant and uv.y * some random constant
    return fract(
        43758.5453 * sin(
            dot(
                vec2(seed.x + uv.x * 0.2294 + 0.42323 * frameCount, seed.y + uv.y * 0.245 + 0.71223 * frameCount),
                vec2(12.9898, 78.233)
            )
        )
    );
}
#pragma endregion
