shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

// =============================================================================
// TWO PUPPIES: THE GREAT ADVENTURE — AAA STYLIZED ANIMATED GRASS SHADER
// Inspired by Hazelight's "It Takes Two" and Pixar feature film foliage:
// - Physical dual-octave wind ripples with rolling wind gust brightness
// - Backlight translucency (sunlight glowing through translucent blade tips)
// - Dynamic interactive puppy trample deflection (Bruno & Milo displace grass)
// - 3-stop vertical color gradient: deep root, lush blade body, golden sunlit tips
// =============================================================================

uniform vec4 root_color : source_color = vec4(0.08, 0.22, 0.06, 1.0);
uniform vec4 mid_color  : source_color = vec4(0.26, 0.58, 0.16, 1.0);
uniform vec4 tip_color  : source_color = vec4(0.72, 0.90, 0.24, 1.0);

uniform float wind_speed       : hint_range(0.5, 6.0) = 2.4;
uniform float wind_strength    : hint_range(0.0, 0.6) = 0.18;
uniform float wind_turbulence  : hint_range(0.0, 2.0) = 0.85;

// Interactive player trampling
uniform vec3 bruno_pos = vec3(0.0, -999.0, 0.0);
uniform vec3 milo_pos  = vec3(0.0, -999.0, 0.0);
uniform float trample_radius : hint_range(0.5, 3.0) = 1.35;
uniform float trample_strength : hint_range(0.0, 1.0) = 0.65;

void vertex() {
	// Root vertices (UV.y close to 0) stay anchored into the soil.
	// Upper blade vertices (UV.y approaching 1) sway freely.
	float sway = clamp(UV.y, 0.0, 1.0);
	float sway_sq = sway * sway; // Quadratic curve for realistic bending stiffness
	
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// 1. Dual-frequency rolling wind displacement
	float wave_large = sin(TIME * wind_speed + world_pos.x * 0.35 + world_pos.z * 0.25);
	float wave_ripple = cos(TIME * (wind_speed * 1.8) + world_pos.x * 0.9 - world_pos.z * 0.7) * wind_turbulence;
	float wind_displacement = (wave_large * 0.7 + wave_ripple * 0.3) * wind_strength * sway_sq;
	
	VERTEX.x += wind_displacement;
	VERTEX.z += wind_displacement * 0.6;
	
	// 2. Interactive Puppy Trample Deflection
	// Calculate distance to Bruno
	vec2 diff_bruno = world_pos.xz - bruno_pos.xz;
	float dist_bruno = length(diff_bruno);
	if (dist_bruno < trample_radius && dist_bruno > 0.01) {
		float push_factor = (1.0 - (dist_bruno / trample_radius)) * trample_strength * sway;
		vec2 push_dir = normalize(diff_bruno);
		VERTEX.x += push_dir.x * push_factor * 0.45;
		VERTEX.z += push_dir.y * push_factor * 0.45;
		VERTEX.y -= push_factor * 0.25; // Flatten down toward ground
	}
	
	// Calculate distance to Milo
	vec2 diff_milo = world_pos.xz - milo_pos.xz;
	float dist_milo = length(diff_milo);
	if (dist_milo < trample_radius && dist_milo > 0.01) {
		float push_factor = (1.0 - (dist_milo / trample_radius)) * trample_strength * sway;
		vec2 push_dir = normalize(diff_milo);
		VERTEX.x += push_dir.x * push_factor * 0.45;
		VERTEX.z += push_dir.y * push_factor * 0.45;
		VERTEX.y -= push_factor * 0.25;
	}
	
	// 3. Normal Softening: Upward-biased normal for soft volumetric cartoon lighting
	NORMAL = normalize(mix(NORMAL, vec3(0.0, 1.0, 0.0), 0.65));
}

void fragment() {
	float h = clamp(UV.y, 0.0, 1.0);
	
	// 3-stop vertical color transition
	vec3 blade_color;
	if (h < 0.40) {
		blade_color = mix(root_color.rgb, mid_color.rgb, h / 0.40);
	} else {
		blade_color = mix(mid_color.rgb, tip_color.rgb, (h - 0.40) / 0.60);
	}
	
	ALBEDO = blade_color;
	ROUGHNESS = 0.52;
	SPECULAR = 0.22;
	
	// Backlight translucency: sun shines through thin grass blade tips
	BACKLIGHT = vec3(0.35, 0.55, 0.15) * h;
}
