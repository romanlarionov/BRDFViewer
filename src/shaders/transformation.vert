
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

uniform float theta;
uniform float roughness;
uniform sampler2D ltc_Minv;
uniform sampler2D ltc_Amp;

attribute vec3 position;

varying vec3 P;

mat3 transpose(mat3 v)
{
    mat3 tmp;
    tmp[0] = vec3(v[0].x, v[1].x, v[2].x);
    tmp[1] = vec3(v[0].y, v[1].y, v[2].y);
    tmp[2] = vec3(v[0].z, v[1].z, v[2].z);

    return tmp;
} 

void main()
{
    vec2 uv = vec2(roughness, theta / 1.570795);
    vec4 t = texture2D(ltc_Minv, uv);
    float amp = texture2D(ltc_Amp, uv).x;

    vec3 v0 = vec3(1.0, 0.0, t.y);
    vec3 v1 = vec3(0.0, t.z, 0.0);
    vec3 v2 = vec3(t.w, 0.0, t.x);
    mat3 Minv = mat3(v0, v1, v2);

    vec3 V = vec3(sin(theta), 0.0, cos(theta));
    vec3 N = vec3(0.0, 0.0, 1.0);
    vec3 T = normalize(V - N*dot(N, V));
    vec3 B = cross(N, T);
    //Minv = Minv * transpose(mat3(T, B, N));

    vec3 w_position = 1000.0 * (Minv * position);
    /*if (position.x == 0.0)
        gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);
    else*/
        gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(w_position, 1.0);

    P = w_position;
}