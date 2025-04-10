// Simple passthrough fragment shader
varying vec2 v_texcoord;

uniform lowp vec3 u_old[32];
uniform lowp vec3 u_new[32];

void main() {
	gl_FragColor = texture2D(gm_BaseTexture, v_texcoord);
	
	for (int i = 0; i < 32; i++) {
		if (distance(gl_FragColor.rgb, u_old[i]) < 0.0001) {
			gl_FragColor.rgb = u_new[i];
			
			break;
		}
	}
}