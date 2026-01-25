shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// --- 1. DARKNESS & CONTRAST (THE FIX) ---
uniform float brightness : hint_range(0.0, 1.0) = 0.5; // Controls overall light
uniform float contrast : hint_range(1.0, 3.0) = 1;   // Controls how dark the shadows are
uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.5; // Dark corners

// --- 2. PIXELATION ---
uniform float pixel_factor : hint_range(1.0, 10.0) = 2.0;

// --- 3. COLOR SETTINGS ---
uniform float glitch_strength : hint_range(0.0, 0.05) = 0.01; 
uniform vec4 left_glitch_color : source_color = vec4(1.0, 0.0, 1.0, 0.5); 
uniform vec4 right_glitch_color : source_color = vec4(0.0, 1.0, 0.0, 0.5); 

// --- 4. SHAKE & BLOCKS ---
uniform float glitch_power : hint_range(0.0, 0.05) = 0.02; 
uniform float glitch_rate : hint_range(0.0, 1.0) = 0.02;   
uniform float idle_shake_power : hint_range(0.0, 0.02) = 0.01; 
uniform float idle_shake_speed : hint_range(0.0, 100.0) = 1.0; 
uniform float block_size : hint_range(5.0, 50.0) = 20.0; 
uniform float block_rate : hint_range(0.0, 1.0) = 0.05;

float random(vec2 seed) {
	return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	vec2 resolution = VIEWPORT_SIZE;
	vec2 uv = SCREEN_UV;
	
	// A. SHAKE & BLOCKS
	float idle_x = sin(TIME * idle_shake_speed) * idle_shake_power;
	float idle_y = cos(TIME * (idle_shake_speed * 0.9)) * idle_shake_power;
	uv += vec2(idle_x, idle_y);
	
	vec2 block_uv = floor(uv * block_size);
	float block_time = floor(TIME * 15.0);
	if (random(vec2(block_time, block_uv.y * block_uv.x)) > (1.0 - block_rate)) {
		uv.x += (random(block_uv) - 0.5) * 0.2;
	}

	// B. PIXELATION & STRIP GLITCH
	vec2 grid_uv = floor(uv * (resolution / pixel_factor)) / (resolution / pixel_factor);
	
	float time_val = floor(TIME * 20.0);
	if (random(vec2(time_val, grid_uv.y)) > (1.0 - glitch_rate)) {
		grid_uv.x += sin(grid_uv.y * 20.0) * glitch_power;
	}
	
	// C. GET TEXTURE COLORS
	vec3 main_image = texture(screen_texture, grid_uv).rgb;
	vec3 left_ghost = texture(screen_texture, grid_uv + vec2(glitch_strength, 0.0)).rgb;
	vec3 right_ghost = texture(screen_texture, grid_uv - vec2(glitch_strength, 0.0)).rgb;
	
	// D. APPLY DARKNESS (The Fix)
	// 1. Apply Contrast (Makes dark things darker, keeps lights bright)
	main_image = pow(main_image, vec3(contrast));
	left_ghost = pow(left_ghost, vec3(contrast));
	right_ghost = pow(right_ghost, vec3(contrast));
	
	// 2. Apply Brightness (Dims everything)
	main_image *= brightness;
	
	// E. COMBINE (Don't just Add!)
	// Instead of adding (which creates white), we colorize the ghosts
	vec3 final_color = main_image;
	
	// Mix in the colored ghosts subtly
	final_color = mix(final_color, left_ghost * left_glitch_color.rgb, 0.5);
	final_color = mix(final_color, right_ghost * right_glitch_color.rgb, 0.5);

	// F. VIGNETTE
	float dist = distance(SCREEN_UV, vec2(0.5));
	final_color *= (1.0 - dist * vignette_intensity);

	ALBEDO = final_color;
}