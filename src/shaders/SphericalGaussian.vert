
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

struct SphericalGaussian {
  float amplitude;
  float sharpness;
  vec3 mean;
};

float evaluate(const in SphericalGaussian a, const in vec3 direction) {
    return a.amplitude * exp(dot(a.mean, direction) * a.sharpness - a.sharpness);
}

SphericalGaussian createSg(const in vec3 normal, const in float roughness4) {
    SphericalGaussian res;
    res.mean = normal;
    res.sharpness = 2.0 / roughness4;

    float b = 2.0 * M_PI / res.sharpness;
    res.amplitude = 1.0 / (exp(-2.0 * res.sharpness) * -b + b);
    return res;
}

SphericalGaussian map(const in SphericalGaussian hv_sg, const in vec3 reflection, const in float NdotV) {
    SphericalGaussian res;
    res.amplitude = hv_sg.amplitude;
    res.sharpness = hv_sg.sharpness * 0.25 / NdotV;
    res.mean = reflection;
    return res;
}

float Smith_Shadowing_Masking(float roughness4, float NdotX)
{
    float NdotX2 = NdotX * NdotX;
    float G = 0.5 * (-1.0 + sqrt(1.0 + roughness4 * (1.0 - NdotX2) / NdotX));
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
    vec3 view       = vec3(sin(theta), 0.0, cos(theta));
    vec3 light_dir  = normalize(w_position);
    vec3 halfway    = normalize(light_dir + view);
    vec3 reflection = normalize(reflect(-view, vec3(0.0, 0.0, 1.0)));

    float NdotL = max(light_dir.z, 0.0);
    float NdotV = max(view.z, 0.0);
    float VdotH = max(dot(view, halfway), 0.0);
    float roughness4 = roughness * roughness * roughness * roughness;

    SphericalGaussian hv_sg = createSg(vec3(0.0, 0.0, 1.0), roughness4);
    SphericalGaussian l_sg  = map(hv_sg, reflection, NdotV);
    float brdf = evaluate(l_sg, light_dir);

    brdf /= 4.0 * NdotL * NdotV;
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