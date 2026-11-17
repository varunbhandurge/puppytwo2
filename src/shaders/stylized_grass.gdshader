shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

// Premium Stylized Animated-Film Grass Shader
// Features vertex wind displacement, 3-stop vertical color gradient, and sun translucency

uniform vec4 root_color : source_color = vec4(0.12, 0.28, 0.08, 1.0);
uniform vec4 mid_color : source_color = vec4(0.28, 0.65, 0.18, 1.0);
uniform vec4 tip_color : source_color = vec4(0.78, 0.88, 0.25, 1.0);

uniform float wind_speed : hint_range(0.1, 5.0) = 1.8;
uniform float wind_strength : hint_range(0.0, 1.5) = 0.35;
uniform float wind_turbulence : hint_range(0.1, 4.0) = 1.2;

varying float v_height;

void vertex() {
	// UV.y is 0 at top of blade, 1 at root
	v_height = 1.0 - UV.y;
	
	// Wind displacement scales with blade height (roots stay grounded)
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float wave_a = sin(TIME * wind_speed + world_pos.x * wind_turbulence + world_pos.z * 0.5);
	float wave_b = cos(TIME * wind_speed * 0.8 + world_pos.z * wind_turbulence * 1.3);
	
	vec3 sway = vec3(wave_a + wave_b * 0.5, 0.0, wave_b * 0.7) * wind_strength * pow(v_height, 1.5);
	VERTEX += sway;
	
	// Soften normals to create lush fluffy field look rather than harsh flat quads
	NORMAL = mix(NORMAL, vec3(0.0, 1.0, 0.0), 0.6);
}

void fragment() {
	// 3-stop color blend: root -> mid -> sunlit tip
	vec3 base_blend = mix(root_color.rgb, mid_color.rgb, smoothstep(0.0, 0.5, v_height));
	vec3 final_albedo = mix(base_blend, tip_color.rgb, smoothstep(0.5, 1.0, v_height));
	
	ALBEDO = final_albedo;
	ROUGHNESS = 0.65;
	SPECULAR = 0.15;
	
	// Backlighting translucency (subsurface glow when sunlight shines through blades)
	BACKLIGHT = tip_color.rgb * 0.4 * v_height;
}
