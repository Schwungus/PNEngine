varying vec2 v_texcoord;
varying vec4 v_color;

uniform sampler2D u_light_texture;
uniform lowp vec4 u_light_uvs;
uniform vec2 u_light_repeat;

uniform vec4 u_dark_color;

uniform lowp vec2 u_bleed; // factor, threshold

void main() {
	vec2 frac = fract(v_texcoord * u_light_repeat);
	vec2 uv = vec2(mix(u_light_uvs.r, u_light_uvs.b, frac.x), mix(u_light_uvs.g, u_light_uvs.a, frac.y));
	
	vec4 dark = texture2D(gm_BaseTexture, v_texcoord);
	vec4 light = texture2D(u_light_texture, uv);
	
	float gray = 0.21 * dark.r + 0.71 * dark.g + 0.07 * dark.b;
	
	gl_FragColor = v_color * mix(dark, mix(u_dark_color, light, step(u_bleed.y, gray)), u_bleed.x);
}