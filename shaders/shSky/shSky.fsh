/* -------------------
   SKY FRAGMENT SHADER
   ------------------- */

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec4 v_color;

/* --------
   UNIFORMS
   -------- */

uniform lowp vec4 u_uvs;
uniform vec4 u_color;

void main() {
	gl_FragColor = v_color * texture2D(gm_BaseTexture, vec2(mix(u_uvs.r, u_uvs.b, fract(v_texcoord.x)), mix(u_uvs.g, u_uvs.a, fract(v_texcoord.y)))) * u_color;
}