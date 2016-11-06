
precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

varying vec3 P;
varying vec3 N;

void main() {
    vec3 w_position = modelMatrix * position;
    vec3 w_normal = vec3(0.0, 0.0, 1.0);
    //N = normalMatrix * normal;
    //P = vec3(modelMatrix * vec4(position, 1.0));

    vec4 C1 = vec4(2.0, 0.0, 0.0, 0.0);
    vec4 C2 = vec4(0.0, 1.1, 0.0, 0.0);
    vec4 C3 = vec4(3.0, 0.0, 1.5, 0.0);
    vec4 C4 = vec4(0.0, 0.0, 0.0, 1.0);
    mat4 T =  mat4(C1, C2, C3, C4);

    gl_Position =  projectionMatrix * viewMatrix * vec4(w_position, 1.0);
}