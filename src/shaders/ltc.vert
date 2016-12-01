
precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

attribute vec3 position;
attribute vec3 normal;

varying vec3 c_P;
varying vec3 c_N;
varying mat4 viewMat;

void main()
{
    c_P = vec3(viewMatrix * modelMatrix * vec4(position, 1.0));
    c_N = normalMatrix * normal;
    viewMat = viewMatrix;
    gl_Position = projectionMatrix * vec4(c_P, 1.0);
}