
precision mediump float;
precision mediump int;

uniform vec3 camera;
uniform samplerCube envMap;
uniform vec3 normalFresnel;

varying vec3 Position;
varying vec3 Normal;

// Schlick approximation for fresnel of degree incidence other than 0
vec3 computeFresnel(vec3 dir, vec3 norm) {
    norm = normalize(norm);
    dir = normalize(dir);
    vec3 halfway = normalize(norm + dir);

    float cosTheta = max(dot(halfway, dir), 0.0);

    vec3 res = vec3(1.0);
    res.r = normalFresnel.r + (1.0 - normalFresnel.r) * pow(1.0 - cosTheta, 5.0);
    res.g = normalFresnel.g + (1.0 - normalFresnel.g) * pow(1.0 - cosTheta, 5.0);
    res.b = normalFresnel.b + (1.0 - normalFresnel.b) * pow(1.0 - cosTheta, 5.0);
    return res;
}

void main() {
    vec3 normal = normalize(Normal);
    vec3 viewDir = normalize(Position - camera);
    vec3 reflection = reflect(viewDir, normal);
    vec3 color = textureCube(envMap, reflection).rgb;
    vec3 fresnel = computeFresnel(viewDir, normal);
    color = vec3(color.r * fresnel.r, color.g * fresnel.g, color.b * fresnel.b);

    gl_FragColor = vec4(color, 1.0);
}