/**
 * Falling Snow Shader (White Particles)
 * 
 * Adapted from the Starfield shader by Martijn Steinrucken ("The Art of Code")
 * Modified to create white snow particles falling vertically.
 */

shader_type canvas_item;

uniform vec2 VIEWPORT_SIZE = vec2(1280, 720);
uniform float fall_speed : hint_range(0.0, 2.0) = 0.2;  // vitesse de chute
uniform float opacity : hint_range(0.0, 1.0) = 1.0;     // intensité globale
uniform float density : hint_range(1.0, 20.0) = 8.0;    // densité (nb de couches)

#define NUM_LAYERS 8.0

float Hash21(vec2 p) {
    p = fract(p * vec2(123.23, 456.34));
    p += dot(p, p + 45.45);
    return fract(p.x * p.y);
}

float Snow(vec2 uv, float size) {
    float d = length(uv);
    float m = smoothstep(0.05, 0.0, d) * size;
    return m;
}

vec3 SnowLayer(vec2 uv, float t) {
    vec3 col = vec3(0.0);
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y));
            float n = Hash21(id + offset);
            float flake_size = fract(n * 534.0) * 0.8 + 0.2;
            float y_offset = fract(t + n) - 0.5;

            vec2 p = gv - offset + vec2(sin(TIME * 0.5 + n * 20.0) * 0.2, y_offset);
            float flake = Snow(p, flake_size);
            float flicker = sin(TIME * 2.0 + n * 10.0) * 0.5 + 1.0;

            col += vec3(1.0) * flake * flicker;
        }
    }
    return col;
}

void fragment() {
    vec2 fragCoord = UV * VIEWPORT_SIZE;
    vec2 uv = fragCoord / VIEWPORT_SIZE;

    // t = position verticale qui boucle
    float t = mod(TIME * fall_speed, 1.0);

    vec3 col = vec3(0.0);

    // plusieurs couches de neige à des vitesses différentes
    for (float i = 0.0; i < 1.0; i += 1.0 / density) {
        float depth = fract(i + t);
        float scale = mix(10.0, 0.5, depth);
        float fade = depth * smoothstep(1.0, 0.8, depth);
        col += SnowLayer(uv * scale + vec2(0.0, depth * 10.0), TIME + i * 10.0) * fade;
    }

    float brightness = clamp(length(col), 0.0, 1.0);
    COLOR = vec4(vec3(brightness), brightness * opacity);
}
