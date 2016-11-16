
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
uniform float plotLog;
uniform sampler2D ltc_Minv;
uniform sampler2D ltc_Amp;

attribute vec3 position;
attribute vec3 normal;

uniform vec3 shading_light;

varying vec3 P;
varying vec3 N;
varying vec3 L;
varying vec3 C;

const float LUT_SIZE  = 64.0;
const float LUT_SCALE = (LUT_SIZE - 1.0)/LUT_SIZE;
const float LUT_BIAS  = 0.5/LUT_SIZE;

float moveToLogSpace(float x)
{
    return log(x + 1.0) * 0.434294482;
}

void main()
{
    float th = -M_PI/2.0;
    float p = M_PI;
    vec3 v0 = vec3(cos(p), -sin(p), 0.0);
    vec3 v1 = vec3(sin(p), cos(p)*cos(th), sin(th));
    vec3 v2 = vec3(0.0, -sin(th), cos(th));
    mat3 rotation = mat3(v0, v1, v2);

    vec3 w_position = vec3(modelMatrix * vec4(position, 0.0));
    vec3 view = normalize(w_position);
    float NdotV = max(view.z, 0.0);
    float view_theta = acos(NdotV);
    float view_phi = acos(view.x / sin(view_theta));

    //float balance = (view_phi >= M_PI) ? -1.0 : 1.0;

    vec2 uv = vec2(roughness, view_theta / 1.570795);
    uv = uv * LUT_SCALE + LUT_BIAS;
    vec4 t = texture2D(ltc_Minv, uv);
    float amp = texture2D(ltc_Amp, uv).w;

    float q = (t.x - (t.y * t.w));

    vec3 m0 = vec3(t.x, 0.0, -t.y);
    vec3 m1 = vec3(0.0, q / t.z, 0.0);
    vec3 m2 = vec3(-t.w, 0.0, 1.0);

    vec3 n0 = vec3(1.0, 0.0, t.y);
    vec3 n1 = vec3(0.0, t.z, 0.0);
    vec3 n2 = vec3(t.w, 0.0, t.x);

    mat3 M = (1.0 / q) * mat3(m0, m1, m2);
    mat3 Minv = mat3(n0, n1, n2);

    vec3 light_dir_transformed = normalize(vec3(sin(theta), 0.0, cos(theta)));
    vec3 light_dir_original    = Minv * light_dir_transformed;
    vec3 light_dir_original_n  = normalize(light_dir_original);

    float norm = length(light_dir_transformed); // should be 1
    float detMinv = t.z * q;//(t.x * t.z) - (t.y * t.z * t.w);
    float detM = 1.0 / detMinv;
    //float detM = ((t.x - (t.y * t.z)) / t.z) * (t.x - (t.y * t.w));
    float jacobian = detM / (norm * norm * norm);

    float D0 = (1.0 / M_PI) * max(light_dir_original_n.z, 0.0);
    float result = amp * D0 / jacobian;

    //D = (plotLog > 0.5) ? moveToLogSpace(D) : D;

    C = (t.x >= 0.0) ? vec3(1.0) : vec3(0.0);
    vec3 transformed_position = rotation * normalize(M * view) * result * NdotV * 25.0;

    // Used for actual shading
    gl_Position = projectionMatrix * viewMatrix * vec4(transformed_position, 1.0);

    N = normalMatrix * normal;
    P = vec3(viewMatrix * vec4(w_position, 1.0));
    L = vec3(viewMatrix * vec4(shading_light, 1.0));
}