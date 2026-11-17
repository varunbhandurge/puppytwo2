shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// =============================================================================
// TWO PUPPIES: THE GREAT ADVENTURE — AAA STYLIZED FOREST FLOOR SHADER
// "The Whispering Forest" Biome:
// - Rich damp loam soil, pine needles, and decaying leaf litter
// - Organic velvet moss patches on rock edges and tree bases
// - Tactile normal perturbation for organic soil depth
// - Specular wetness blending along stream banks and muddy hollows
// =============================================================================

uniform vec4 soil_base_color : source_color = vec4(0.20, 0.14, 0.09, 1.0);
uniform vec4 soil_wet_color  : source_color = vec4(0.12, 0.08, 0.05, 1.0);
uniform vec4 moss_color      : source_color = vec4(0.16, 0.42, 0.12, 1.0);
uniform vec4 pine_needle_col : source_color = vec4(0.38, 0.24, 0.14, 1.0);

uniform float moss_frequency   : hint_range(0.05, 1.0) = 0.22;
uniform float moss_amount      : hint_range(0.0, 1.0) = 0.48;
uniform float detail_frequency : hint_range(10.0, 100.0) = 48.0;
uniform float wetness_distance : hint_range(1.0, 20.0) = 5.0;

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

// Fractal Brownian Motion
float fbm(vec2 p) {
	float total = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 3; i++) {
		total += amplitude * noise(p);
		p *= 2.08;
		amplitude *= 0.5;
	}
	return total;
}

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// 1. Organic moss patches
	float moss_noise = fbm(world_pos.xz * moss_frequency);
	float moss_factor = smoothstep(1.0 - moss_amount - 0.15, 1.0 - moss_amount + 0.15, moss_noise);
	
	// 2. Micro pine needles and leaf litter grain
	float micro_grain = noise(world_pos.xz * detail_frequency);
	float needle_mask = smoothstep(0.4, 0.8, noise(world_pos.xz * 12.0));
	
	vec3 soil = mix(soil_base_color.rgb, pine_needle_col.rgb, needle_mask * 0.4);
	soil += (micro_grain - 0.5) * 0.08;
	
	// 3. Stream proximity wetness (stream flows near center z = 0)
	float stream_proximity = smoothstep(wetness_distance, 0.0, abs(world_pos.z));
	vec3 base_ground = mix(soil, soil_wet_color.rgb, stream_proximity * 0.65);
	
	// Blend moss over ground
	vec3 final_color = mix(base_ground, moss_color.rgb, moss_factor * 0.88);
	
	// 4. Procedural Normal Perturbation (soil & moss texture)
	vec2 eps = vec2(0.04, 0.0);
	float n_c = noise(world_pos.xz * detail_frequency);
	float n_r = noise((world_pos.xz + eps.xy) * detail_frequency);
	float n_u = noise((world_pos.xz + eps.yx) * detail_frequency);
	vec3 bump_normal = normalize(vec3((n_c - n_r) * 1.5, 1.0, (n_c - n_u) * 1.5));
	
	ALBEDO = clamp(final_color, vec3(0.0), vec3(0.95));
	NORMAL = mix(NORMAL, bump_normal, 0.35);
	ROUGHNESS = mix(0.85, 0.35, stream_proximity * 0.7); // Muddy areas are glossy/reflective
	SPECULAR = mix(0.12, 0.45, stream_proximity * 0.7);
}
