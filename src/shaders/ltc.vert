
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
uniform sampler2D ltc_M;
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
    // float NdotV = max(view.z, 0.0);
    float NdotV = view.z;
    float view_theta = min(max(acos(NdotV), 0.0), 1.570795);
    //float view_theta = atan(sqrt(view.x * view.x + view.y * view.y) / view.z); //atan(view.y/view.x);

    //float NdotH = max(dot(w_normal, halfway), 0.0);
    //float VdotH = max(dot(view, halfway), 0.0);

    vec2 uv = vec2(roughness, view_theta / 1.570795);
    uv = uv * LUT_SCALE + LUT_BIAS;
    vec4 t = texture2D(ltc_M, uv);

    vec3 m0 = vec3(1.0, 0.0, -t.y);
    vec3 m1 = vec3(0.0, (t.x - (t.y * t.z)) / t.z, 0.0);
    vec3 m2 = vec3(-t.w, 0.0, t.x);

    vec3 n0 = vec3(t.x, 0.0, t.y);
    vec3 n1 = vec3(0.0, t.z, 0.0);
    vec3 n2 = vec3(t.w, 0.0, 1.0);

    mat3 M = mat3(m0, m1, m2);
    mat3 Minv = mat3(n0, n1, n2);

    float amp = texture2D(ltc_Amp, uv).x;
    
    /*vec3 m0 = vec3(0.7, 0.0, 0.0);
    vec3 m1 = vec3(0.0, 0.2, 0.0);
    vec3 m2 = vec3(0.4, 0.0, 1.0);
    mat3 M = mat3(m0, m1, m2);*/

    //vec3 light_dir_transformed = normalize(vec3(sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta)));
    vec3 light_dir_original = Minv * normalize(vec3(sin(theta), 0.0, cos(theta)));
    vec3 light_dir_transformed = M * normalize(light_dir_original);
    vec3 light_dir_original_n = normalize(light_dir_original);

    float norm = length(light_dir_transformed);
    float detMinv = (t.x * 10.0 * t.z) - (t.y * t.z * t.w);
    float detM = ((t.x - (t.y * t.z)) / t.z) * (t.x - (t.y * t.w));
    float jacobian = detM / (norm * norm * norm);
    //float jacobian = max(detMinv / (norm * norm * norm), 0.1);
    //float jacobian = detMinv / (norm * norm * norm);

    float D0 = (1.0 / M_PI) * max(light_dir_original_n.z, 0.0);
    float result = amp * D0 / 0.0;

    //D = (plotLog > 0.5) ? moveToLogSpace(D) : D;

    C = vec3(detMinv);
    //vec3 transformed_position = normalize(M * view) * D0 * jacobian;// * result;
    vec3 transformed_position = normalize(rotation * M * view) * result;

    // I dont think I can actually do this. If I transform the light direction,
    // and calculate the brdf value then I'm just calculating the lambertian
    // distribution for a single light direction. D_0 is only defined as a distribution
    // so I would have to have to sample for a number of incident light directions 
    // to get a good representation. It doesn't make much sense to do a single sample
    // direction defined by theta. 

    // Used for actual shading
    gl_Position = projectionMatrix * viewMatrix * vec4(transformed_position, 1.0);

    N = normalMatrix * normal;
    P = vec3(viewMatrix * vec4(w_position, 1.0));
    L = vec3(viewMatrix * vec4(shading_light, 1.0));
}