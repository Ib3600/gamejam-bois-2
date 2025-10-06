/**
 * Falling Snow Shader (Pixelated Snow - Clean version)
 *
 * Rendu plus fin et naturel : petits flocons pixelisés, chute fluide.
 */

shader_type canvas_item;

uniform vec2 VIEWPORT_SIZE = vec2(1280, 720);
uniform float fall_speed : hint_range(0.0, 2.0) = 0.3;  // vitesse de chute
uniform float opacity : hint_range(0.0, 1.0) = 1.0;     // intensité globale
uniform float density : hint_range(1.0, 20.0) = 8.0;    // nombre de couches
uniform float pixel_size : hint_range(1.0, 5.0) = 1.5;  // taille des pixels visibles

float Hash21(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.56);
    return fract(p.x * p.y);
}

// Flocon avec bords nets
float Snow(vec2 uv, float size) {
    uv = floor(uv * 64.0 / pixel_size) / (64.0 / pixel_size);
    float d = length(uv);
    return step(d, 0.015 + 0.01 * (1.0 - size)); // petits cercles nets
}

vec3 SnowLayer(vec2 uv, float t) {
    vec3 col = vec3(0.0);
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            float n = Hash21(id + offset);
            float flake_size = fract(n * 534.0) * 0.6 + 0.4;
            float y_offset = fract(t + n) - 0.5;

            vec2 p = gv - offset + vec2(sin(TIME * 0.3 + n * 10.0) * 0.05, y_offset);
            float flake = Snow(p, flake_size);
            col += vec3(1.0) * flake;
        }
    }
    return col;
}

void fragment() {
    vec2 fragCoord = UV * VIEWPORT_SIZE;
    vec2 uv = fragCoord / VIEWPORT_SIZE;

    float t = mod(TIME * fall_speed, 1.0);
    vec3 col = vec3(0.0);

    for (float i = 0.0; i < 1.0; i += 1.0 / density) {
        float depth = fract(i + t);
        float scale = mix(10.0, 1.0, depth);
        float fade = depth * smoothstep(1.0, 0.8, depth);
        col += SnowLayer(uv * scale + vec2(0.0, depth * 10.0), TIME + i * 10.0) * fade;
    }

    float brightness = clamp(length(col), 0.0, 1.0);
    COLOR = vec4(vec3(brightness), brightness * opacity);
}
