shader_type canvas_item;

uniform float radius;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 local_coords = (UV - center);
	float distance = length(local_coords);

	float circleRadius = radius / float(2);

	if (distance > circleRadius) {
		discard;
	}
	// Called for every vertex the material is visible on.
}
