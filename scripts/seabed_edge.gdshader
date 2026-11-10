shader_type canvas_item;

uniform sampler2D sand_texture : source_color, filter_linear;
uniform float surface_y = 1120.0;
uniform float solid_sand_y = 1165.0;

varying vec4 tint;

void vertex() {
	tint = COLOR;
}

void fragment() {
	float source_height = 1.0 / TEXTURE_PIXEL_SIZE.y;
	float y = UV.y * source_height;
	if (y < surface_y) {
		COLOR = vec4(0.0);
	} else {
		float progress = (y - surface_y) / (source_height - surface_y);
		float fill_y = mix(solid_sand_y, source_height, progress) / source_height;
		vec4 sand = texture(sand_texture, vec2(UV.x, fill_y));
		vec4 original = texture(TEXTURE, UV);
		COLOR = vec4(mix(sand.rgb, original.rgb, original.a), 1.0) * tint;
	}
}
