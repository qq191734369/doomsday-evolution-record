shader_type canvas_item;

uniform float avatar_size : hint_range(0.0, 1.0) = 0.5;
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec2 uv = UV - vec2(0.475);
	float dist = length(uv);
	float circle = smoothstep(avatar_size, avatar_size - smoothness, dist);
	COLOR.a *= circle;
}
