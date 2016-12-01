
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

const float LUT_SIZE  = 64.0;
const float LUT_SCALE = (LUT_SIZE - 1.0)/LUT_SIZE;
const float LUT_BIAS  = 0.5/LUT_SIZE;

uniform sampler2D ltc_Minv;
uniform sampler2D ltc_Amp;
uniform vec3 w_light_corners[4];
uniform vec3 intensity;
uniform vec3 normalFresnel;

varying vec3 c_P;
varying vec3 c_N;
varying mat4 viewMat;

mat3 transpose(mat3 v)
{
    mat3 tmp;
    tmp[0] = vec3(v[0].x, v[1].x, v[2].x);
    tmp[1] = vec3(v[0].y, v[1].y, v[2].y);
    tmp[2] = vec3(v[0].z, v[1].z, v[2].z);

    return tmp;
}

float contourIntegral(vec3 p1, vec3 p2)
{
    float theta = acos(dot(p1, p2));
    return -cross(p1, p2).z * ((theta > 0.001) ? theta/sin(theta) : 1.0);
}

float LTC_Evaluate(vec3 normal, vec3 view, vec3 position, vec2 uv)
{
    vec4 t = texture2D(ltc_Minv, uv);
    mat3 Minv = mat3(
        vec3(1.0, 0.0, t.y),
        vec3(0.0, t.z, 0.0),
        vec3(t.w, 0.0, t.x)
    );

    // Construct tangent space around fragment
    vec3 tangent = normalize(view - normal * dot(normal, view));
    vec3 bitangent = normalize(cross(normal, tangent));

    mat3 TBN = mat3(tangent, bitangent, normal);
    Minv = Minv * transpose(TBN);

    vec3 c_light_corners[4];
    c_light_corners[0] = TBN * vec3(viewMat * vec4(w_light_corners[0], 1.0));
    c_light_corners[1] = TBN * vec3(viewMat * vec4(w_light_corners[1], 1.0));
    c_light_corners[2] = TBN * vec3(viewMat * vec4(w_light_corners[2], 1.0));
    c_light_corners[3] = TBN * vec3(viewMat * vec4(w_light_corners[3], 1.0));

    vec3 tbn_position = TBN * position;

    // Transform to fitted space and project onto unit hemisphere
    vec3 t_light_corners[4];
    t_light_corners[0] = normalize(Minv * (c_light_corners[0] - tbn_position));
    t_light_corners[1] = normalize(Minv * (c_light_corners[1] - tbn_position));
    t_light_corners[2] = normalize(Minv * (c_light_corners[2] - tbn_position));
    t_light_corners[3] = normalize(Minv * (c_light_corners[3] - tbn_position));

    float irradiance = 0.0;
    irradiance += contourIntegral(t_light_corners[0], t_light_corners[1]);
    irradiance += contourIntegral(t_light_corners[1], t_light_corners[2]);
    irradiance += contourIntegral(t_light_corners[2], t_light_corners[3]);
    irradiance += contourIntegral(t_light_corners[3], t_light_corners[0]);

    return abs(irradiance / (2.0 * M_PI));
}

void main()
{
    vec3 view = -normalize(vec3(c_P));
    vec3 normal = normalize(c_N);

    float theta = acos(dot(normal, view));

    vec2 r_uv = vec2(0.0, theta / (0.5 * M_PI));
    vec2 g_uv = vec2(0.3, theta / (0.5 * M_PI));
    vec2 b_uv = vec2(0.66, theta / (0.5 * M_PI));

    float r_spec = LTC_Evaluate(normal, view, c_P, r_uv) * texture2D(ltc_Amp, r_uv).a;
    float g_spec = LTC_Evaluate(normal, view, c_P, g_uv) * texture2D(ltc_Amp, g_uv).a;
    float b_spec = LTC_Evaluate(normal, view, c_P, b_uv) * texture2D(ltc_Amp, b_uv).a;
    vec3 specular = vec3(r_spec);

    vec3 ambient = vec3(0.95, 0.64, 0.54);

    gl_FragColor = vec4(0.66 * ambient + specular * intensity, 1.0);
}