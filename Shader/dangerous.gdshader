shader_type spatial;

// 1. SETTINGS:
// unshaded = Dili maapektohan sa shadows (siga permi)
// depth_test_disabled = WALLHACK (makita luyo sa bungbong)
// blend_add = Nindot nga mixing sa colors (mura siyag hologram)
// cull_disabled = Makita both sides
render_mode unshaded, depth_test_disabled, blend_add, cull_disabled;

void vertex() {
	// 2. BILLBOARD EFFECT
	// Kini nga math nagsiguro nga ang Quad KANUNAY mag-atubang sa Camera.
	// Bisag asa ka molingi, lingin gihapon siya tan-awon.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
		vec4(1.0, 0.0, 0.0, 0.0), 
		vec4(0.0, 1.0, 0.0, 0.0), 
		vec4(0.0, 0.0, 1.0, 0.0), 
		MODEL_MATRIX[3]
	);
}

void fragment() {
	// 3. HIMOANG LINGIN (MATH)
	// Kuhaon ang distansya gikan sa tunga (0.5, 0.5)
	float dist = distance(UV, vec2(0.5));
	
	// Baliktaron ang value: Gusto nato 1.0 sa tunga (hayag), 0.0 sa kilid (ngitngit)
	// Ang "* 2.0" para mohaum siya sakto sa square borders
	float glow = 1.0 - (dist * 2.0);
	
	// Siguraduhon nga dili mo-negative ang value
	glow = clamp(glow, 0.0, 1.0);
	
	// "Pow" function para himoong SOFT ang glow (dili gahi ang gradient)
	// I-adjust ang "2.0" ngadto sa "4.0" kung gusto ka mas gamay nga bola
	glow = pow(glow, 2.5);

	// 4. WHITE HOT COLOR
	// I-multiply og dako nga number (10.0) para "Overexposed" ug mo-trigger sa Bloom
	ALBEDO = vec3(1.0, 1.0, 1.0) * 10.0;
	
	// 5. TRANSPARENCY
	// Kini ang moputol sa Box. Kung 0 ang glow (sa kanto), invisible na siya.
	ALPHA = glow;
}