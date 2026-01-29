shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec4 night_vision_color : source_color = vec4(0.1, 1.0, 0.1, 1.0); // Green
uniform float brightness_boost : hint_range(0.0, 5.0) = 2.0;
uniform float noise_amount : hint_range(0.0, 1.0) = 0.2;
uniform float scanline_count : hint_range(0.0, 1000.0) = 200.0;
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.0;

// BAG-O: Threshold para mahimong puti (Thermal Effect)
uniform float white_hot_threshold : hint_range(0.0, 5.0) = 1.5; 

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 pixelColor = texture(screen_texture, SCREEN_UV);
	
	// Check unsa kahayag ang pixel
	float original_brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
	
	// --- THE FIX: THERMAL HOT CHECK ---
	// Kung ang kahayag sa object nilapas sa threshold, HIMOANG PUTI
	if (original_brightness > 0.8) { 
		// "Overexposed" - Ignore Green, Force White
		COLOR = vec4(1.0, 1.0, 1.0, 1.0); 
	} 
	else {
		// --- NORMAL NIGHT VISION LOGIC ---
		vec3 visionColor = night_vision_color.rgb * original_brightness * brightness_boost;
		
		// Scanlines
		float scanline = sin(SCREEN_UV.y * scanline_count) * 0.05;
		visionColor -= scanline;
		
		// Noise
		float noise = random(UV + vec2(TIME, 0.0)) * noise_amount;
		visionColor += (noise * 0.05);
		
		// Vignette
		float dist = distance(UV, vec2(0.5));
		visionColor *= (1.0 - dist * vignette_strength);
		
		COLOR = vec4(visionColor, 1.0);
	}
}