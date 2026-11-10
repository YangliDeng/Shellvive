shader_type canvas_item;

uniform bool outline_only = false;
uniform float animation_time = 0.0;
uniform float motion_pixels = 6.0;
uniform float animation_fps = 6.666667;

varying vec4 tint;

float red_ink(vec4 pigment, vec2 pixel) {
	float red = step(pigment.g * 1.1, pigment.r)
		* step(pigment.b * 1.08, pigment.r) * step(0.25, pigment.r);
	bool mouth = pixel.x >= 140.0 && pixel.x <= 260.0
		&& pixel.y >= 230.0 && pixel.y <= 310.0;
	return mouth ? 0.0 : red;
}

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec2 sample_uv = UV;
	if (outline_only) {
		float tick = mod(floor(animation_time * animation_fps), 4.0);
		vec2 wave = vec2(sin(UV.y * 12.0 + tick * 2.7), cos(UV.x * 10.0 + tick * 1.9));
		sample_uv += wave * motion_pixels * TEXTURE_PIXEL_SIZE;
	}
	vec4 pigment = texture(TEXTURE, sample_uv);
	float ink = red_ink(pigment, sample_uv / TEXTURE_PIXEL_SIZE);
	COLOR = pigment * tint;
	COLOR.a *= outline_only ? ink : 1.0 - ink;
}
