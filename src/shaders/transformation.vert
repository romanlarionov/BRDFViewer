
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform float theta;
uniform float roughness;
uniform sampler2D ltc_Minv;
uniform sampler2D ltc_Amp;
uniform float norm;

attribute vec3 position;

varying vec3 P;

const float LUT_SIZE  = 64.0;
const float LUT_SCALE = (LUT_SIZE - 1.0)/LUT_SIZE;
const float LUT_BIAS  = 0.5/LUT_SIZE;

void main()
{
    vec2 uv = vec2(roughness, theta / 1.570795);
    uv = uv * LUT_SCALE + LUT_BIAS;
    vec4 t = texture2D(ltc_Minv, uv);
    float amp = texture2D(ltc_Amp, uv).w;

    vec3 v0 = vec3(1.0, 0.0, t.y);
    vec3 v1 = vec3(0.0, t.z, 0.0);
    vec3 v2 = vec3(t.w, 0.0, t.x);
    mat3 Minv = mat3(v0, v1, v2);

    vec4 w_position = modelMatrix * vec4(position, 1.0);
    vec3 t_position = Minv * vec3(w_position);
    t_position = (norm > 0.5) ? normalize(t_position) : t_position;
    gl_Position = projectionMatrix * viewMatrix * vec4(t_position, 1.0);

    P = t_position;
}