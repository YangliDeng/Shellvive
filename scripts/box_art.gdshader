shader_type canvas_item;

uniform sampler2D body_mask : filter_nearest;
uniform vec2 frame_size = vec2(634.0, 568.0);
uniform bool markings_only = false;
uniform float body_bottom_y = 263.0;

void fragment() {
	vec2 frame_uv = mod(UV / TEXTURE_PIXEL_SIZE, frame_size) / frame_size;
	vec3 pigment = texture(TEXTURE, UV).rgb;
	float gold = step(0.32, pigment.r) * step(0.23, pigment.g)
		* step(pigment.b * 1.15, min(pigment.r, pigment.g));
	float markings = (1.0 - texture(body_mask, frame_uv).a) * gold;
	COLOR.a *= markings_only ? markings : 1.0 - markings;
	if (!markings_only) {
		COLOR.a *= step(frame_uv.y * frame_size.y, body_bottom_y);
	}
}
