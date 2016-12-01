
precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

uniform vec3 w_light_corners[4];

attribute vec3 position;
attribute vec3 normal;

varying vec3 c_P;
varying vec3 c_N;
varying vec3 c_light_corners[4];

void main()
{
    for (int i = 0; i < 4; i++)
        c_light_corners[i] = vec3(viewMatrix * vec4(w_light_corners[i], 1.0));

    c_P = vec3(viewMatrix * modelMatrix * vec4(position, 1.0));
    c_N = normalMatrix * normal;
    gl_Position = projectionMatrix * vec4(c_P, 1.0);
}