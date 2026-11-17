shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx, depth_draw_always;

// Stylized River & Shoreline Water Shader
// Dynamic surface wave displacement, depth-based color gradients, and animated shoreline foam

uniform vec4 deep_water_color : source_color = vec4(0.1, 0.35, 0.65, 0.88);
uniform vec4 shallow_water_color : source_color = vec4(0.2, 0.72, 0.82, 0.7);
uniform vec4 foam_color : source_color = vec4(0.95, 0.98, 1.0, 1.0);

uniform float wave_speed : hint_range(0.1, 5.0) = 1.6;
uniform float wave_frequency : hint_range(0.5, 10.0) = 2.4;
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.08;
uniform float foam_threshold : hint_range(0.05, 1.5) = 0.35;

uniform sampler2D depth_texture : hint_depth_texture;

void vertex() {
	// Sinusoidal dual-direction surface wave displacement
	float wave1 = sin(VERTEX.x * wave_frequency + TIME * wave_speed);
	float wave2 = cos(VERTEX.z * (wave_frequency * 0.8) + TIME * (wave_speed * 1.2));
	VERTEX.y += (wave1 + wave2) * wave_amplitude * 0.5;
}

void fragment() {
	// Read depth buffer to calculate shoreline proximity
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	world_view.xyz /= world_view.w;
	
	float depth_diff = -world_view.z - VERTEX.z;
	
	// Water color gradient from shallow to deep
	float depth_factor = clamp(depth_diff * 0.5, 0.0, 1.0);
	vec3 water_color = mix(shallow_water_color.rgb, deep_water_color.rgb, depth_factor);
	
	// Animated shoreline foam line
	float foam_wave = sin(TIME * (wave_speed * 2.0) + (UV.x + UV.y) * 12.0) * 0.05;
	float foam_line = 1.0 - smoothstep(0.0, foam_threshold + foam_wave, depth_diff);
	
	vec3 final_color = mix(water_color, foam_color.rgb, clamp(foam_line, 0.0, 1.0));
	
	ALBEDO = final_color;
	ALPHA = mix(shallow_water_color.a, deep_water_color.a, depth_factor);
	ROUGHNESS = 0.15;
	SPECULAR = 0.8;
}
