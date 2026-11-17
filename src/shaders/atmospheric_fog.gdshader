shader_type spatial;
render_mode cull_disabled, unshaded, blend_mix, depth_draw_never;

// Stylized Atmospheric Height Fog & Volumetric Light Beam Shader
// Soft geometric depth intersection and height-gradient falloff for forest and mountain ambiances

uniform vec4 fog_color : source_color = vec4(0.75, 0.85, 0.95, 0.45);
uniform float fog_density : hint_range(0.01, 2.0) = 0.4;
uniform float height_falloff : hint_range(0.1, 10.0) = 2.5;
uniform float drift_speed : hint_range(0.01, 1.0) = 0.15;

uniform sampler2D depth_texture : hint_depth_texture;

void fragment() {
	// Sample depth buffer for soft intersection fade
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	world_view.xyz /= world_view.w;
	
	float depth_diff = -world_view.z - VERTEX.z;
	float soft_fade = clamp(depth_diff * 0.8, 0.0, 1.0);
	
	// Height gradient calculation
	float height_gradient = clamp(1.0 - (VERTEX.y / height_falloff), 0.0, 1.0);
	
	// Animated drift fluctuation
	float drift = sin(TIME * drift_speed + UV.x * 4.0) * cos(TIME * (drift_speed * 0.8) + UV.y * 4.0) * 0.15;
	float final_alpha = fog_color.a * fog_density * soft_fade * (height_gradient + drift);
	
	ALBEDO = fog_color.rgb;
	ALPHA = clamp(final_alpha, 0.0, 1.0);
}
