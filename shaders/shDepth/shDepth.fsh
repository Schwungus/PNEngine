// PIXEL ÜBERSHADER (DEPTH)

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec4 v_color;
varying float v_light_depth;

/* --------
   UNIFORMS
   -------- */

uniform vec2 u_texture_size;
uniform float u_max_lod;
uniform vec4 u_mipmaps[12];
uniform int u_mipmap_filter;

uniform vec4 u_color;

uniform vec4 u_material_color;
uniform float u_material_alpha_test;
uniform float u_material_bright;

uniform int u_material_can_blend;
uniform sampler2D u_material_blend;
uniform vec4 u_material_blend_uvs;

// By genpfault
float mipmap_level(in vec2 texels) {
	vec2 dx_vtc = dFdx(texels);
	vec2 dy_vtc = dFdy(texels);
	float delta_max_sqr = dot(dx_vtc, dx_vtc) + dot(dy_vtc, dy_vtc);
	
	return 0.5 * log2(delta_max_sqr);
}

// By FabriceNeyret2, ollj, Tech_
float bayer2(vec2 a) {
	a = floor(a);
	
	return fract(dot(a, vec2(0.5, a.y * 0.75)));
}

#define bayer4(a) (bayer2(0.5 * a) * 0.25 + bayer2(a))
#define bayer8(a) (bayer4(0.5 * a) * 0.25 + bayer2(a))

void main() {
	// Mipmapping
	float u = fract(v_texcoord.x);
	float v = fract(v_texcoord.y);
	float lod = clamp(mipmap_level(v_texcoord * u_texture_size), 0., u_max_lod);
	vec4 sample;
	
	if (bool(u_mipmap_filter)) {
		vec4 mma = u_mipmaps[int(min(lod + 1., u_max_lod))];
		vec4 mmb = u_mipmaps[int(lod)];
		
		vec2 uva = vec2(mix(mma.r, mma.b, u), mix(mma.g, mma.a, v));
		vec2 uvb = vec2(mix(mmb.r, mmb.b, u), mix(mmb.g, mmb.a, v));
		
		sample = mix(texture2D(gm_BaseTexture, uvb), texture2D(gm_BaseTexture, uva), fract(lod));
	} else {
		vec4 mipmap = u_mipmaps[int(lod)];
		vec2 uv = vec2(mix(mipmap.r, mipmap.b, u), mix(mipmap.g, mipmap.a, v));
		
		sample = texture2D(gm_BaseTexture, uv);
	}
	
	// Texture blending
	float v_alpha;
	
	if (bool(u_material_can_blend)) {
		vec2 blend_uv = vec2(mix(u_material_blend_uvs.r, u_material_blend_uvs.b, u), mix(u_material_blend_uvs.g, u_material_blend_uvs.a, v));
		
		sample = mix(texture2D(u_material_blend, blend_uv), sample, v_color.a);
		v_alpha = 1.;
	} else {
		v_alpha = v_color.a;
	}
	
	// Alpha testing
	if (u_material_alpha_test > 0.) {
		if (sample.a < u_material_alpha_test) {
			discard;
		}
		
		sample.a = 1.;
	}
	
	gl_FragColor = (sample * u_material_color * vec4(v_color.rgb, mix(v_alpha, 0., u_material_bright))) * u_color;
	
	// Screen-door transparency
	if (gl_FragColor.a <= (bayer8(gl_FragCoord.xy) + 0.003921568627451)) {
		discard;
	}
	
	gl_FragColor = vec4(v_light_depth, 0, 0, 1);
}