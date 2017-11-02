# Aurora Demo
Aurora is a realtime path tracing demo. We will be extending conventional path tracing by adding secondary bounces, allowing for indirect illumination. The result will be lighting that is much more physically accurate than raytracing, which is limited to direct lighting.

## Tentative Architecture
We intend to create a small, self-sufficient demo application that solely offers interactive mouse control for controlling the camera position. The demo will contain a number of pre-defined spheres and one point light in a Cornell box.

Implementation-wise, we will be building the application with OpenGL for GPU acceleration (providing the ability to simulate lighting in realtime). Though the application will be built in C++, practically all heavylifting will be handled by our path tracing shader.

Our highest development priority is safety. We don't want to be in a situation where we aren't able to show any results when the project is due; and due to the sheer extent of a full path tracer, this is very likely to happen if we are not careful. As a result, we are pre-defining as much as we can: the entire scene will be statically defined in the GLSL shader. If we are able to reach our goals in a very short time, then *we may consider* extending the demo by supporting other geometric primitives (triangles especially) and loading scenes dynamically from a file. But I should emphasize that these are within our core deliverables.

## Core Deliverables
- Single-window (unresizeable) application
- Cornell box with a number of spheres
- Indirect illumination using path tracing
- Camera orbiting using mouse dragging

## Developers
- Eun Kyung Yoon
- Michael Ortiz
- Yusuf Olokoba
