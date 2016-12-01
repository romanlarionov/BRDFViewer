
precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

attribute vec3 position;
attribute vec3 normal;

varying vec3 w_P;
varying vec3 w_N;

void main()
{
    w_P = vec3( modelMatrix * vec4(position, 1.0));
    w_N = normal * 2.0 - 1.0;
    w_N = vec3(modelMatrix * vec4(w_N, 0.0));
    gl_Position = projectionMatrix * viewMatrix * vec4(w_P, 1.0);
}