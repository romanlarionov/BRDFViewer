
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform float roughness; // sqrt(alpha)
uniform float theta;
uniform float F0;
uniform float plotLog;
uniform sampler2D ltc_Minv;
uniform sampler2D ltc_Amp;

attribute vec3 position;

uniform vec3 shading_light;

varying vec3 P;
varying vec3 L;

const float LUT_SIZE  = 64.0;
const float LUT_SCALE = (LUT_SIZE - 1.0)/LUT_SIZE;
const float LUT_BIAS  = 0.5/LUT_SIZE;

float SchlickFresnel(float VdotH, float F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
}

float moveToLogSpace(float x)
{
    return log(x + 1.0) * 0.434294482;
}

void main()
{
    // Input sphere not oriented correctly in model space. i.e. hack
    float th = -M_PI/2.0;
    float p = M_PI;
    vec3 v0 = vec3(cos(p), -sin(p), 0.0);
    vec3 v1 = vec3(sin(p), cos(p)*cos(th), sin(th));
    vec3 v2 = vec3(0.0, -sin(th), cos(th));
    mat3 rotation = mat3(v0, v1, v2);

    vec3 w_position = vec3(modelMatrix * vec4(position, 0.0));
    vec3 light_dir  = normalize(w_position);
    vec3 view       = vec3(sin(theta), 0.0, cos(theta));

    vec2 uv = vec2(roughness, theta / 1.570795);
    uv = uv * LUT_SCALE + LUT_BIAS; // used in sample demo
    vec4 t = texture2D(ltc_Minv, uv);
    float amp = texture2D(ltc_Amp, uv).w;

    // Rescaling term omitted from LUT
    float q = (t.x - (t.y * t.w));

    vec3 m0 = vec3(t.x, 0.0, -t.y);
    vec3 m1 = vec3(0.0, q / t.z, 0.0);
    vec3 m2 = vec3(-t.w, 0.0, 1.0);

    vec3 n0 = vec3(1.0, 0.0, t.y);
    vec3 n1 = vec3(0.0, t.z, 0.0);
    vec3 n2 = vec3(t.w, 0.0, t.x);

    mat3 M = (1.0 / q) * mat3(m0, m1, m2);
    mat3 Minv = mat3(n0, n1, n2);

    // all below: refer to https://github.com/romanlarionov/LTC_Fitting/blob/master/LTC.h
    vec3 sample_transformed_n = normalize(M * light_dir);
    vec3 sample_original = normalize(Minv * sample_transformed_n);
    vec3 sample_transformed = M * sample_original;

    float norm = length(sample_transformed);
    float detMinv = t.z * q;
    float detM = 1.0 / detMinv;
    float jacobian = detM / (norm * norm * norm);
    float D = (1.0 / M_PI) * max(sample_original.z, 0.0);
    float result = amp * D / jacobian;

    result = (plotLog > 0.5) ? moveToLogSpace(result) : result;

    vec3 halfway    = normalize(sample_transformed_n + view);
    float VdotH     = max(dot(view, halfway), 0.0);
    float NdotL     = max(sample_transformed_n.z, 0.0);
    float fresnel   = SchlickFresnel(VdotH, F0);

    vec3 t_position = rotation * sample_transformed * result * fresnel * NdotL / NdotL;

    // Used for actual shading
    gl_Position = projectionMatrix * viewMatrix * vec4(t_position, 1.0);

    P = vec3(viewMatrix * vec4(t_position, 1.0));
    L = vec3(viewMatrix * vec4(shading_light, 1.0));
}