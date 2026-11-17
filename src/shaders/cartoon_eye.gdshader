shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// Stylized Animated-Film Cartoon Eye Shader
// Renders large expressive pupils, layered iris gradients, and shiny corneal catchlights

uniform vec4 sclera_color : source_color = vec4(0.96, 0.95, 0.93, 1.0);
uniform vec4 iris_outer_color : source_color = vec4(0.32, 0.16, 0.06, 1.0);
uniform vec4 iris_inner_color : source_color = vec4(0.72, 0.48, 0.18, 1.0);
uniform vec4 pupil_color : source_color = vec4(0.03, 0.03, 0.04, 1.0);

uniform float iris_radius : hint_range(0.1, 0.5) = 0.36;
uniform float pupil_radius : hint_range(0.05, 0.3) = 0.18;
uniform vec2 sparkle_pos = vec2(0.09, -0.09);
uniform float sparkle_radius : hint_range(0.01, 0.15) = 0.06;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 uv_dist = UV - center;
	float dist = length(uv_dist);
	
	vec3 final_color = sclera_color.rgb;
	
	// Iris rendering
	if (dist < iris_radius) {
		float iris_t = smoothstep(pupil_radius, iris_radius, dist);
		vec3 iris_blend = mix(iris_inner_color.rgb, iris_outer_color.rgb, iris_t);
		
		// Subtle radial iris fiber pattern
		float angle = atan(uv_dist.y, uv_dist.x);
		float fibers = 0.92 + 0.08 * sin(angle * 24.0);
		iris_blend *= fibers;
		
		// Pupil rendering
		if (dist < pupil_radius) {
			float pupil_edge = smoothstep(pupil_radius - 0.02, pupil_radius, dist);
			final_color = mix(pupil_color.rgb, iris_blend, pupil_edge);
		} else {
			final_color = iris_blend;
		}
		
		// Outer limbal ring darkening
		float limbal = smoothstep(iris_radius - 0.03, iris_radius, dist);
		final_color = mix(final_color, iris_outer_color.rgb * 0.5, limbal);
	}
	
	// Stylized primary white sparkle catchlight
	float sparkle_dist = length(uv_dist - sparkle_pos);
	if (sparkle_dist < sparkle_radius) {
		float sparkle_edge = smoothstep(sparkle_radius, sparkle_radius * 0.7, sparkle_dist);
		final_color = mix(final_color, vec3(1.0, 1.0, 1.0), sparkle_edge);
	}
	
	// Secondary smaller sparkle catchlight
	vec2 secondary_pos = sparkle_pos * -0.65;
	float sec_sparkle_dist = length(uv_dist - secondary_pos);
	if (sec_sparkle_dist < sparkle_radius * 0.5) {
		float sec_edge = smoothstep(sparkle_radius * 0.5, sparkle_radius * 0.3, sec_sparkle_dist);
		final_color = mix(final_color, vec3(1.0, 1.0, 1.0), sec_edge * 0.85);
	}
	
	ALBEDO = final_color;
	ROUGHNESS = 0.05; // Glossy cornea reflection
	SPECULAR = 0.9;
}
