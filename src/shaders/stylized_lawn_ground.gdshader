shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// =============================================================================
// TWO PUPPIES: THE GREAT ADVENTURE — AAA PROCEDURAL LAWN GROUND SHADER
// Inspired by Hazelight's "It Takes Two" suburban garden aesthetics:
// - Alternating directional manicured mowing stripes with specular sheen
// - Micro-fiber sod bump mapping for tactile grass turf feel
// - Organic macro color patches (sun-warmed lime, lush emerald, damp moss)
// - Organic soil/dirt path blending around garden boundaries and stepping stones
// =============================================================================

uniform vec4 grass_sunlit_color : source_color = vec4(0.32, 0.68, 0.22, 1.0);
uniform vec4 grass_shadow_color : source_color = vec4(0.16, 0.42, 0.12, 1.0);
uniform vec4 grass_moss_color   : source_color = vec4(0.12, 0.32, 0.10, 1.0);
uniform vec4 soil_color         : source_color = vec4(0.22, 0.15, 0.10, 1.0);
uniform vec4 soil_worn_color    : source_color = vec4(0.35, 0.26, 0.18, 1.0);

uniform float stripe_frequency : hint_range(0.1, 3.0) = 0.55;
uniform float stripe_intensity : hint_range(0.0, 1.0) = 0.35;
uniform float fiber_frequency  : hint_range(10.0, 120.0) = 55.0;
uniform float soil_blend_dist  : hint_range(5.0, 30.0) = 18.0;

// High-speed pseudo-random hash
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// 2D Value Noise with Hermite interpolation
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal Brownian Motion for rich organic ground variation
float fbm(vec2 p) {
	float total = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 3; i++) {
		total += amplitude * noise(p);
		p *= 2.05;
		amplitude *= 0.5;
	}
	return total;
}

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// 1. Manicured diagonal lawn roller stripes (45-degree angle typical of suburban estates)
	float stripe_coord = (world_pos.x * 0.7071 + world_pos.z * 0.7071) * stripe_frequency;
	float stripe_wave = sin(stripe_coord);
	float stripe_mask = smoothstep(-0.25, 0.25, stripe_wave);
	
	// 2. Multi-scale procedural turf color variation
	float macro_var = fbm(world_pos.xz * 0.18);
	float micro_grain = noise(world_pos.xz * fiber_frequency);
	
	vec3 base_lawn = mix(grass_shadow_color.rgb, grass_sunlit_color.rgb, stripe_mask * stripe_intensity + (1.0 - stripe_intensity) * 0.5);
	base_lawn = mix(base_lawn, grass_moss_color.rgb, clamp(macro_var * 0.45 - 0.1, 0.0, 0.4));
	base_lawn += (micro_grain - 0.5) * 0.09;
	
	// 3. Procedural Normal Perturbation (micro sod & grass fiber tactile relief)
	vec2 eps = vec2(0.04, 0.0);
	float n_c = noise(world_pos.xz * fiber_frequency) * 0.6 + noise(world_pos.xz * 8.0) * 0.4;
	float n_r = noise((world_pos.xz + eps.xy) * fiber_frequency) * 0.6 + noise((world_pos.xz + eps.xy) * 8.0) * 0.4;
	float n_u = noise((world_pos.xz + eps.yx) * fiber_frequency) * 0.6 + noise((world_pos.xz + eps.yx) * 8.0) * 0.4;
	vec3 turf_normal = normalize(vec3((n_c - n_r) * 1.8, 1.0, (n_c - n_u) * 1.8));
	
	// 4. Organic soil blending near outer fence perimeter
	float dist_x = abs(world_pos.x);
	float fence_dirt_factor = smoothstep(soil_blend_dist - 2.5, soil_blend_dist + 2.0, dist_x);
	
	// 5. Pathway soil wear along the central puppy run
	float path_wear = smoothstep(1.8, 0.2, abs(world_pos.x)) * smoothstep(12.0, -18.0, world_pos.z) * 0.35;
	float total_soil = clamp(fence_dirt_factor + path_wear, 0.0, 1.0);
	
	vec3 ground_soil = mix(soil_color.rgb, soil_worn_color.rgb, micro_grain * 0.5);
	vec3 final_albedo = mix(base_lawn, ground_soil, total_soil * 0.85);
	
	// 6. Outputs
	ALBEDO = clamp(final_albedo, vec3(0.0), vec3(0.96));
	NORMAL = mix(NORMAL, turf_normal, 0.45 * (1.0 - total_soil * 0.5));
	ROUGHNESS = mix(0.72, 0.92, total_soil);
	SPECULAR = mix(0.22, 0.08, total_soil);
}
