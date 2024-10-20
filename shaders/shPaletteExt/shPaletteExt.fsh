// Simple passthrough fragment shader
varying vec2 v_texcoord;

uniform vec4 u_old[32];
uniform vec4 u_new[32];

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_texcoord);
	
	for (int i = 0; i < 32; i++) {
		if (distance(gl_FragColor, u_old[i]) < 0.0001) {
			gl_FragColor = u_new[i];
			
			break;
		}
	}
}