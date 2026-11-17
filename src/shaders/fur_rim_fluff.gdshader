shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// Premium Stylized Canine Fur Shader
// Simulates velvety fur softness, warm directional rim highlighting, and gentle shading
// Strictly avoids HDR bloom over-exposure

uniform vec4 fur_base_color : source_color = vec4(0.85, 0.65, 0.35, 1.0);
uniform vec4 fur_rim_color : source_color = vec4(0.95, 0.85, 0.65, 1.0);
uniform vec4 shadow_tint : source_color = vec4(0.55, 0.38, 0.22, 1.0);
uniform float rim_power : hint_range(0.5, 6.0) = 3.0;
uniform float rim_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float fur_roughness : hint_range(0.0, 1.0) = 0.85;

void fragment() {
	// Fresnel rim calculation based on view angle and surface normal
	float n_dot_v = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(1.0 - n_dot_v, rim_power);
	
	// Soft blend clamped so color values never exceed 1.0 (prevents HDR neon glow)
	float blend_factor = clamp(fresnel * rim_intensity, 0.0, 0.45);
	vec3 albedo_result = mix(fur_base_color.rgb, fur_rim_color.rgb, blend_factor);
	
	ALBEDO = clamp(albedo_result, vec3(0.0), vec3(0.95));
	ROUGHNESS = fur_roughness;
	SPECULAR = 0.12;
}
