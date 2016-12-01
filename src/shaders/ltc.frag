
#define M_PI 3.1415926535897932384626433832795

precision mediump float;
precision mediump int;

uniform sampler2D ltc_Minv;
uniform sampler2D ltc_Amp;
uniform vec3 w_light_corners[4];
uniform vec3 intensity;
uniform vec3 normalFresnel;
uniform vec3 camera_position;

varying vec3 w_P;
varying vec3 w_N;

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
    return cross(p1, p2).z * ((theta > 0.001) ? theta/sin(theta) : 1.0);
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

    // Transform to fitted space and project onto unit hemisphere
    vec3 t_light_corners[4];
    t_light_corners[0] = normalize(Minv * (w_light_corners[0] - position));
    t_light_corners[1] = normalize(Minv * (w_light_corners[1] - position));
    t_light_corners[2] = normalize(Minv * (w_light_corners[2] - position));
    t_light_corners[3] = normalize(Minv * (w_light_corners[3] - position));

    float irradiance = 0.0;
    irradiance += contourIntegral(t_light_corners[0], t_light_corners[1]);
    irradiance += contourIntegral(t_light_corners[1], t_light_corners[2]);
    irradiance += contourIntegral(t_light_corners[2], t_light_corners[3]);
    irradiance += contourIntegral(t_light_corners[3], t_light_corners[0]);

    return irradiance / (2.0 * M_PI);
}

void main()
{
    vec3 view = -normalize(vec3(w_P - camera_position));
    vec3 normal = normalize(w_N);

    float theta = acos(dot(normal, view));

    vec2 r_uv = vec2(0.0, theta / (0.5 * M_PI));
    vec2 g_uv = vec2(0.3333, theta / (0.5 * M_PI));
    vec2 b_uv = vec2(0.6666, theta / (0.5 * M_PI));

    float r_spec = LTC_Evaluate(normal, view, w_P, r_uv) * -texture2D(ltc_Amp, r_uv).a;
    float g_spec = LTC_Evaluate(normal, view, w_P, g_uv) * texture2D(ltc_Amp, g_uv).a;
    float b_spec = LTC_Evaluate(normal, view, w_P, b_uv) * texture2D(ltc_Amp, b_uv).a;
    vec3 specular = vec3(r_spec, g_spec, b_spec);

    gl_FragColor = vec4( specular * intensity, 1.0);
}