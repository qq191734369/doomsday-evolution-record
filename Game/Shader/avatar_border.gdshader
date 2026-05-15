shader_type canvas_item;

uniform float border_size : hint_range(0.0, 0.5) = 0.48;
uniform float border_thickness : hint_range(0.0, 0.2) = 0.05;
uniform float smoothness : hint_range(0.0, 0.1) = 0.02;
uniform vec4 border_color : source_color = vec4(1.0);

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);
	float outer = smoothstep(border_size, border_size - smoothness, dist);
	float inner = smoothstep(border_size - border_thickness, border_size - border_thickness - smoothness, dist);
	float border = outer - inner;
	COLOR = vec4(border_color.rgb, border);
}
