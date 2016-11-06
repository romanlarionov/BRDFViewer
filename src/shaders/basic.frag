
precision mediump float;
precision mediump int;

uniform vec3 V;
uniform vec3 L;
uniform vec3 I;
uniform vec3 C;

varying vec3 P;
varying vec3 N;

void main() {
    //N = normalize(N);
    //vec3 viewDir = normalize(P - V);
    //vec3 R = reflect(P - L, N);

    gl_FragColor = vec4(C, 1.0);
}