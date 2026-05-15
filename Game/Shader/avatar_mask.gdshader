shader_type canvas_item;

uniform float avatar_size : hint_range(0.0, 1.0) = 0.45;
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;
uniform bool invincible_effect : hint_range(0.0, 1.0) = false;
uniform float blink : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float circle = smoothstep(avatar_size, avatar_size - smoothness, dist);
	
	if (circle < 0.01) {
		discard;
	}
	
	if (invincible_effect) {
		float blink_effect = sin(TIME * 20.0) * 0.5 + 0.5;
		float blink_value = mix(1.0, blink_effect, blink);
		COLOR = vec4(vec3(blink_value), COLOR.a);
	}
	
	COLOR.a *= circle;
}
