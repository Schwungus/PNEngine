// Simple passthrough fragment shader
varying vec2 v_texcoord;
varying vec4 v_color;

// By FabriceNeyret2, ollj, Tech_
float bayer2(vec2 a) {
	a = floor(a);
	
	return fract(dot(a, vec2(0.5, a.y * 0.75)));
}

#define bayer4(a) (bayer2(0.5 * a) * 0.25 + bayer2(a))

void main() {
	gl_FragColor = v_color * texture2D(gm_BaseTexture, v_texcoord);
	
	if (gl_FragColor.a <= (bayer4(gl_FragCoord.xy) + 0.003921568627451)) {
		discard;
	}
	
	gl_FragColor.a = 1.;
}