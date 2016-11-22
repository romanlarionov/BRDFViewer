
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

uniform float roughness; // sqrt(alpha)
uniform float phi;
uniform float theta;
uniform float F0;
uniform float plotLog;

attribute vec3 position;

uniform vec3 shading_light;

varying vec3 P;
varying vec3 L;

float GGX_NDF(float roughness4, float NdotH)
{
    float b = NdotH * NdotH * (roughness4 - 1.0) + 1.0;
    return roughness4 / (M_PI * b * b);
}

float Beckmann_NDF(float roughness4, vec3 H)
{
    float dx = H.x / H.z;
    float dy = H.y / H.z;
    return exp(-(dx * dx + dy*dy) / roughness4) / (M_PI * roughness4 * H.z * H.z * H.z * H.z);
}

// http://blog.selfshadow.com/publications/s2013-shading-course/karis/s2013_pbs_epic_notes_v2.pdf
float Schlick_Shadowing_Masking(float NdotV, float NdotL)
{
    float k = ((roughness + 1.0) * (roughness + 1.0)) / 8.0;
    float shadowing = NdotV / (NdotV * (1.0 - k) + k);
    float masking = NdotL / (NdotL * (1.0 - k) + k);
    return shadowing * masking;
}

float Smith_Shadowing_Masking(float roughness, float NdotX)
{
    float a = (1.0 / roughness / roughness / tan(acos(NdotX)));
    float G = (a < 1.6) ? 
                (1.0 - 1.259 * a + 0.396*a*a) / (3.535*a + 2.181*a*a)
                : 0.0;
    return 1.0 / (1.0 + G);
}

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
    float t = -M_PI/2.0;
    float p = M_PI;
    vec3 v0 = vec3(cos(p), -sin(p), 0.0);
    vec3 v1 = vec3(sin(p), cos(p)*cos(t), sin(t));
    vec3 v2 = vec3(0.0, -sin(t), cos(t));
    mat3 rotation = mat3(v0, v1, v2);

    vec3 w_position = vec3(modelMatrix * vec4(position, 0.0));
    vec3 w_normal   = vec3(0.0, 0.0, 1.0);
    vec3 light_dir  = normalize(w_position);
    vec3 view       = normalize(vec3(sin(theta), 0.0, cos(theta)));
    vec3 halfway    = normalize(light_dir + view);

    float NdotL = max(light_dir.z, 0.0);
    float NdotV = max(view.z, 0.0);
    float NdotH = max(halfway.z, 0.0);
    float VdotH = max(dot(view, halfway), 0.0);

    float roughness4 = roughness * roughness * roughness * roughness;

    float brdf = 1.0;

    brdf /= 4.0 * NdotL * NdotV;
    brdf *= Beckmann_NDF(roughness4, halfway);
    brdf *= Smith_Shadowing_Masking(roughness, NdotL);
    brdf *= Smith_Shadowing_Masking(roughness, NdotV);
    brdf *= SchlickFresnel(VdotH, F0);

    brdf = (plotLog > 0.5) ? moveToLogSpace(brdf) : brdf;

    w_position = rotation * light_dir * NdotL * brdf;

    // Used for actual shading
    gl_Position = projectionMatrix * viewMatrix * vec4(w_position, 1.0);

    P = vec3(viewMatrix * vec4(w_position, 1.0));
    L = vec3(viewMatrix * vec4(shading_light, 1.0));
}