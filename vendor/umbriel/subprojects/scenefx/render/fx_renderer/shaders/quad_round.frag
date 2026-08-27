#extension GL_OES_standard_derivatives : enable

#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif

varying vec4 v_color;
varying vec2 v_texcoord;

uniform vec2 size;
uniform vec2 position;
uniform float radius_top_left;
uniform float radius_top_right;
uniform float radius_bottom_left;
uniform float radius_bottom_right;

uniform vec2 clip_size;
uniform vec2 clip_position;
uniform float clip_radius_top_left;
uniform float clip_radius_top_right;
uniform float clip_radius_bottom_left;
uniform float clip_radius_bottom_right;

float corner_alpha(vec2 size, vec2 position, bool is_cutout,
		float radius_tl, float radius_tr, float radius_bl, float radius_br);
float rounded_rect_distance(vec2 size, vec2 position,
		float radius_tl, float radius_tr, float radius_bl, float radius_br);

void main() {
	float alpha;
	if (clip_size.x > 0.0 && clip_size.y > 0.0) {
		float outer_dist = rounded_rect_distance(
			size,
			position,
			radius_top_left,
			radius_top_right,
			radius_bottom_left,
			radius_bottom_right
		);
		float inner_dist = rounded_rect_distance(
			clip_size,
			clip_position,
			clip_radius_top_left,
			clip_radius_top_right,
			clip_radius_bottom_left,
			clip_radius_bottom_right
		);
		float ring_dist = max(outer_dist, -inner_dist);
		float antialias = max(fwidth(ring_dist), 1.0) * 0.5;
		float coverage = 1.0 - smoothstep(-antialias, antialias, ring_dist);
		// Preserve the perceived weight of diagonal samples after premultiplied
		// blending. Without this correction a one-pixel arc looks dotted.
		alpha = sqrt(coverage);
	} else {
		alpha = corner_alpha(
			size - 1.0,
			position + 0.5,
			false,
			radius_top_left,
			radius_top_right,
			radius_bottom_left,
			radius_bottom_right
		);
	}

	gl_FragColor = v_color * alpha;
}
