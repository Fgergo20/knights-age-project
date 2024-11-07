shader_type spatial;

render_mode unshaded, cull_disabled; // Unshaded to avoid affecting color, and disable culling if you want two-sided transparency

uniform float wind_strength : hint_range(0.0, 1.0) = 0.2;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wind_frequency : hint_range(0.1, 10.0) = 2.0;

void vertex() {
    vec3 original_position = VERTEX;
    
    // Apply a wave effect to the vertex position to simulate wind movement
    float wave = sin(original_position.x * wind_frequency + TIME * wind_speed);
    
    // Adjust the vertex position based on wind strength and wave
    original_position.x += wave * wind_strength;
    original_position.z += wave * wind_strength * 0.5; // Add some side-to-side motion
    
    VERTEX = original_position;
}
