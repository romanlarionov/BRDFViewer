
precision mediump float;
precision mediump int;

uniform vec3 shading_intensity;
uniform vec3 shading_color;

varying vec3 P;
varying vec3 N;
varying vec3 L;
varying vec3 C;

void main() {
    vec3 normal = normalize(N);
    vec3 viewDir = normalize(P);
    vec3 light_dir = normalize(L - P);
    vec3 reflection = normalize(reflect(-light_dir, normal));

    vec3 diffuse = shading_intensity * max(dot(normal, light_dir), 0.0);
    vec3 specular = shading_intensity * pow(max(dot(reflection, viewDir), 0.0), 64.0);

    vec3 light = diffuse + specular + vec3(0.5);

    // gl_FragColor = vec4(shading_color * light, 1.0);
    gl_FragColor = vec4(C * light, 1.0);
}