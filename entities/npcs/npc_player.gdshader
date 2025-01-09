shader_type canvas_item;


uniform vec4 sick_color: source_color = vec4(0.5, 0.0, 0.5, 0.5);
uniform bool is_sick = false;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	vec4 final_color = tex_color;
	if (is_sick) {
		float strength = 1.0 - UV.y;
		float sine_wave = (sin(TIME * 2.0) * 0.25) + 0.55;
		vec4 blend_color = vec4(sick_color.rgb, strength * sine_wave);

		final_color = mix(tex_color, blend_color, blend_color.a);
		final_color.a *= tex_color.a;
	}
	COLOR = final_color;
}
