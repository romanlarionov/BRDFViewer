
precision mediump float;
precision mediump int;

varying vec3 P;

void main()
{
    gl_FragColor = vec4(P, 1.0);
}