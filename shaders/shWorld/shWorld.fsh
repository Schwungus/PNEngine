// PIXEL ÜBERSHADER (PER-VERTEX)

/* --------
   VARYINGS
   -------- */

varying vec2 v_texcoord;
varying vec2 v_texcoord2;
varying vec4 v_color;
varying vec4 v_lighting;
varying vec2 v_specular;
varying vec2 v_rimlight;
varying float v_fog;

/* --------
   UNIFORMS
   -------- */

uniform highp ivec2 u_texture_size;
uniform mediump float u_max_lod;
uniform lowp vec4 u_mipmaps[12];
uniform lowp int u_mipmap_filter;

uniform vec4 u_color;
uniform vec4 u_stencil;

uniform vec4 u_fog_color;

uniform vec4 u_material_color;
uniform lowp float u_material_alpha_test;

uniform lowp int u_material_can_blend;
uniform sampler2D u_material_blend;
uniform lowp vec4 u_material_blend_uvs;

uniform lowp int u_lightmap_enable_pixel;
uniform sampler2D u_lightmap;
uniform lowp vec4 u_lightmap_uvs;

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
	float lod = clamp(mipmap_level(v_texcoord * float(u_texture_size)), 0., u_max_lod);
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
	
	// Lighting
	vec4 lighting = v_lighting;
	
	if (bool(u_lightmap_enable_pixel)) {
		float lu = fract(v_texcoord2.x);
		float lv = fract(v_texcoord2.y);
		vec2 lightmap_uv = vec2(mix(u_lightmap_uvs.r, u_lightmap_uvs.b, lu), mix(u_lightmap_uvs.g, u_lightmap_uvs.a, lv));
		
		lighting += texture2D(u_lightmap, lightmap_uv);
	}
	
	vec4 starting_color = sample * u_material_color * vec4(v_color.rgb, v_alpha) * lighting;
	
	// GROSS HACK: Prevent stray pixels when anti-aliasing is enabled
	float specular = v_specular.x;
	float rimlight = v_rimlight.x;
	
	if (specular > 0.) { starting_color.rgb += pow(specular, v_specular.y); }
	if (rimlight > 0.) { starting_color.rgb += pow(rimlight, v_rimlight.y); }
	
	starting_color.rgb = mix(starting_color.rgb, u_fog_color.rgb, v_fog);
	starting_color.a *= mix(1., u_fog_color.a, v_fog);
	gl_FragColor = starting_color * u_color;
	
	// Screen-door transparency
	if (gl_FragColor.a <= (bayer8(gl_FragCoord.xy) + 0.003921568627451)) {
		discard;
	}
	
	gl_FragColor.a = 1.;
	
	// Stencil
	gl_FragColor.rgb = mix(gl_FragColor.rgb, u_stencil.rgb, u_stencil.a);
}