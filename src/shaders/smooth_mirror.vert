
precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

varying vec3 Position;
varying vec3 Normal;

void main() {
    Normal = normalMatrix * normal;
    Position = vec3(modelMatrix * vec4(position, 1.0));
    gl_Position =  projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
}