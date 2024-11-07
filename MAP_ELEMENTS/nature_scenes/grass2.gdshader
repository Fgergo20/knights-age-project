shader_type spatial;

render_mode depth_prepass_alpha, cull_disabled, blend_mix; // Use blend_mix for transparency handling
// Texture settings
uniform sampler2D texture_albedo : hint_default_white, repeat_disable;
uniform sampler2D texture_gradient : hint_default_white, repeat_disable;
uniform sampler2D texture_noise : hint_default_white;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0);
uniform vec4 transmission : source_color;
uniform vec4 secondary_color : source_color;
uniform float secondary_attenuation = 0.2;
uniform float grass_height = 1.0;

// Wind settings
uniform vec2 wind_direction = vec2(1, -0.5);
uniform float wind_speed = 1.0;
uniform float wind_strength = 2.0;
uniform float noise_scale = 20.0;

instance uniform float camera_bend_strength : hint_range(0.0, 3.0) = 0.2;

varying float height;

void vertex() {
    height = VERTEX.y;
    vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);

    vec2 uv = world_pos.xz / (noise_scale + 1e-2);
    vec2 panning_uv = uv + fract(TIME * wind_direction * wind_speed);

    float wind = texture(texture_noise, panning_uv).r * 2.0 - 1.0;
    vec2 wind_offset = wind_direction * wind_strength * wind;

    world_pos.xz += wind_offset;

    float ndotv = 1.0 - dot(vec3(0.0, 1.0, 0.0), normalize(INV_VIEW_MATRIX[1].xyz));
    world_pos.xz += INV_VIEW_MATRIX[1].xz * camera_bend_strength * height * ndotv;

    vec4 local_pos = inverse(MODEL_MATRIX) * world_pos;
    VERTEX = local_pos.xyz;
}

void fragment() {
    vec4 tex = texture(texture_albedo, UV);

    // Check against the alpha value
    if (tex.a < alpha_scissor_threshold) {
        discard; // Discard pixels below the threshold
    }

    // Backlight effect
    BACKLIGHT = transmission.rgb;

    // Use the premultiplied alpha values
    ALBEDO = tex.rgb; // Use the RGB values directly
    ALPHA = tex.a; // Use alpha for blending
}