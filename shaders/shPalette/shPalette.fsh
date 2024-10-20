// Simple passthrough fragment shader
varying vec2 v_texcoord;

uniform vec3 u_old[32];
uniform vec3 u_new[32];

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_texcoord);
	
	for (int i = 0; i < 32; i++) {
		if (gl_FragColor.rgb == u_old[i]) {
			gl_FragColor.rgb = u_new[i];
			
			break;
		}
	}
}