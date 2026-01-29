shader_type canvas_item;

// Settings para ma-adjust nimo sa Inspector
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform vec4 night_vision_color : source_color = vec4(0.1, 1.0, 0.1, 1.0); // Green
uniform float brightness_boost : hint_range(0.0, 5.0) = 2.0; // Paka-hayag
uniform float noise_amount : hint_range(0.0, 1.0) = 0.2; // Kagagmayon sa lugas/grain
uniform float scanline_count : hint_range(0.0, 1000.0) = 200.0; // Lines sa TV
uniform float vignette_strength : hint_range(0.0, 2.0) = 1.0; // Kaitom sa kilid

// Function para maghimo og random noise
float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// 1. Kuhaon ang original color sa game scene
	vec4 pixelColor = texture(screen_texture, SCREEN_UV);

	// 2. Himoon og Grayscale (Black & White) base sa hayag
	float brightness = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;

	// 3. I-apply ang Night Vision Color (Green) ug Boost
	vec3 visionColor = night_vision_color.rgb * brightness * brightness_boost;

	// 4. Dugang Scanlines (Horizontal Lines effect)
	float scanline = sin(SCREEN_UV.y * scanline_count) * 0.05;
	visionColor -= scanline;

	// 5. Dugang Noise (Grain effect)
	float noise = random(UV + vec2(TIME, 0.0)) * noise_amount;
	visionColor += (noise * 0.05);

	// 6. Dugang Vignette (Itom sa kilid)
	float dist = distance(UV, vec2(0.5));
	visionColor *= (1.0 - dist * vignette_strength);

	// Final Output
	COLOR = vec4(visionColor, 1.0);
}