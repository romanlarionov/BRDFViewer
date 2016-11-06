
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;

uniform float roughness; // sqrt(alpha)
uniform float phi;
uniform float theta;
uniform float F0;
uniform vec3 light;

attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

varying vec3 P;
varying vec3 N;

float GGX_NDF(float roughness4, float NdotH)
{
    float b = NdotH * NdotH * (roughness4 - 1.0) + 1.0;
    return roughness4 / (M_PI * b * b);
}

// http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float Smith_Shadowing_Masking(float NdotV, float NdotL)
{
    float k = ((roughness + 1.0) * (roughness + 1.0)) / 8.0;
    float shadowing = NdotV / (NdotV * (1.0 - k) + k);
    float masking = NdotL / (NdotL * (1.0 - k) + k);
    return shadowing * masking;
}

float SchlickFresnel(float VdotH, float F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - VdotH, 5.0);
}

void main()
{
    vec3 w_position  = vec3(modelMatrix * vec4(position, 0.0));
    vec3 w_normal    = vec3(0.0, 0.0, 1.0);
    vec3 w_camera    = vec3(sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi));
    vec3 view      = normalize(w_camera - w_position);
    vec3 light_dir = normalize(light - w_position);
    vec3 halfway   = normalize(light_dir + w_normal);

    float NdotL = max(dot(w_normal, light_dir), 0.0);
    float NdotV = max(dot(w_normal, view), 0.0);
    float NdotH = max(dot(w_normal, halfway), 0.0);
    float VdotH = max(dot(view, halfway), 0.0);

    float roughness4 = roughness * roughness * roughness * roughness;

    float brdf = 1.0;

    brdf /= 4.0 * NdotL * NdotV;
    brdf *= GGX_NDF(roughness4, NdotH);
    brdf *= Smith_Shadowing_Masking(NdotV, NdotL);
    brdf *= SchlickFresnel(VdotH, F0);

    //w_position *= 100.0 * NdotL * NdotL * NdotL * NdotL;//(F0 / (M_PI / 2.0));
    w_position *= 1000.0 * NdotL * brdf;
    gl_Position =  projectionMatrix * viewMatrix * vec4(w_position, 1.0);

    //N = normalMatrix * normal;
    //P = vec3(modelMatrix * vec4(position, 1.0));
}