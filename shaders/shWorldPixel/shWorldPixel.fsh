// PIXEL ÜBERSHADER (PER-PIXEL)

#define LIGHT_SIZE 15
#define MAX_LIGHTS 16
#define MAX_LIGHT_DATA 240

/* --------
   VARYINGS
   -------- */

varying vec3 v_position;
varying vec2 v_texcoord;
varying vec2 v_texcoord2;
varying vec4 v_color;
varying vec3 v_object_space_position;
varying vec3 v_world_normal;
varying vec3 v_view_position;
varying lowp float v_rimlight;

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

uniform mediump float u_material_bright;
uniform vec4 u_material_specular; // specular base+exponent, rimlight b+e
uniform lowp int u_material_half_lambert;
uniform lowp float u_material_cel;

uniform vec4 u_ambient_color;
uniform vec2 u_fog_distance;
uniform float u_light_data[MAX_LIGHT_DATA];
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

float matdot(float dotp) {
	dotp = bool(u_material_half_lambert) ? pow((dotp * 0.5) + 0.5, 2.) : max(dotp, 0.);
	
	return smoothstep(0. + u_material_cel, 1. - u_material_cel, dotp);
}

float matdot(vec3 a, vec3 b) {
	float dotp = bool(u_material_half_lambert) ? pow((dot(a, b) * 0.5) + 0.5, 2.) : max(dot(a, b), 0.);
	
	return smoothstep(0. + u_material_cel, 1. - u_material_cel, dotp);
}

// By FabriceNeyret2, ollj, Tech_
float bayer2(vec2 a) {
	a = floor(a);
	
	return fract(dot(a, vec2(0.5, a.y * 0.75)));
}

#define bayer4(a) (bayer2(0.5 * a) * 0.25 + bayer2(a))
#define bayer8(a) (bayer4(0.5 * a) * 0.25 + bayer2(a))

void main() {
	// Lighting
	vec3 reflection = normalize(reflect(v_view_position, v_world_normal));
	vec4 total_light;
	bool lightmap_enabled = bool(u_lightmap_enable_pixel);
	
	if (lightmap_enabled) {
		float lu = fract(v_texcoord2.x);
		float lv = fract(v_texcoord2.y);
		vec2 lightmap_uv = vec2(mix(u_lightmap_uvs.r, u_lightmap_uvs.b, lu), mix(u_lightmap_uvs.g, u_lightmap_uvs.a, lv));
		
		total_light = texture2D(u_lightmap, lightmap_uv);
	} else {
		total_light = u_ambient_color;
	}
	
	float total_specular = 0.;
	
	for (int i = 0; i < MAX_LIGHT_DATA; i += LIGHT_SIZE) {
		int light_active = int(u_light_data[i + 1]);
		
		if (light_active >= 1 && (!lightmap_enabled || light_active >= 2)) {
			int light_type = int(u_light_data[i]);
			
			if (light_type == 1) { // Directional
				vec3 light_normal = -normalize(vec3(u_light_data[i + 5], u_light_data[i + 6], u_light_data[i + 7]));
				vec4 light_color = vec4(u_light_data[i + 11], u_light_data[i + 12], u_light_data[i + 13], u_light_data[i + 14]);
				
				total_light += matdot(v_world_normal, light_normal) * light_color;
				total_specular += matdot(reflection, light_normal);
			} else if (light_type == 2) { // Point
				vec3 light_position = vec3(u_light_data[i + 2], u_light_data[i + 3], u_light_data[i + 4]);
				float light_start = u_light_data[i + 5];
				float light_end = u_light_data[i + 6];
				vec4 light_color = vec4(u_light_data[i + 11], u_light_data[i + 12], u_light_data[i + 13], u_light_data[i + 14]);
				
				vec3 light_direction = normalize(v_object_space_position - light_position);
				float attenuation = max((light_end - distance(v_object_space_position, light_position)) / (light_end - light_start), 0.);
				
				total_light += attenuation * light_color * matdot(v_world_normal, -light_direction);
				total_specular += attenuation * matdot(reflection, light_direction);
			} else if (light_type == 3) { // Spot
				vec3 light_position = vec3(u_light_data[i + 2], u_light_data[i + 3], u_light_data[i + 4]);
				vec3 light_normal = -normalize(vec3(u_light_data[i + 5], u_light_data[i + 6], u_light_data[i + 7]));
				float light_range = u_light_data[i + 8];
				vec2 light_cutoff = vec2(u_light_data[i + 9], u_light_data[i + 10]);
				vec4 light_color = vec4(u_light_data[i + 11], u_light_data[i + 12], u_light_data[i + 13], u_light_data[i + 14]);
				
				vec3 light_direction = v_object_space_position - light_position;
				float dist = length(light_direction);
				
				light_direction = normalize(-light_direction);
				
				float angle_difference = max(dot(light_direction, light_normal), 0.);
				float cutoff_outer = light_cutoff.y;
				float attenuation = clamp((angle_difference - cutoff_outer) / (light_cutoff.x - cutoff_outer), 0., 1.) * max((light_range - dist) / light_range, 0.);
				
				total_light += attenuation * light_color * matdot(v_world_normal, light_direction);
				total_specular += attenuation * matdot(reflection, light_direction);
			}
		}
	}
	
	total_light = vec4(mix(total_light.rgb, vec3(1.), u_material_bright), min(total_light.a, 1.));
	total_specular = mix(u_material_specular.x * total_specular, 0., u_material_bright);
	
	// Rimlight
	float rimlight = mix(u_material_specular.z * (1. - matdot(v_rimlight)), 0., u_material_bright);
	
	// Fog
	float fog_start = u_fog_distance.x;
	float fog = clamp((length(v_position) - fog_start) / (u_fog_distance.y - fog_start), 0., 1.);
	
	// Mipmapping
	float u = fract(v_texcoord.x);
	float v = fract(v_texcoord.y);
	float lod = clamp(mipmap_level(v_texcoord * float(u_texture_size)), 0., u_max_lod);
	vec4 sample;
	
	if (u_mipmap_filter >= 1) {
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
	
	vec4 starting_color = sample * u_material_color * vec4(v_color.rgb, v_alpha) * total_light;
	
	// GROSS HACK: Prevent stray pixels when anti-aliasing is enabled
	if (total_specular > 0.) { starting_color.rgb += pow(total_specular, u_material_specular.y); }
	if (rimlight > 0.) { starting_color.rgb += pow(rimlight, u_material_specular.w); }
	
	starting_color.rgb = mix(starting_color.rgb, u_fog_color.rgb, fog);
	starting_color.a *= mix(1., u_fog_color.a, fog);
	gl_FragColor = starting_color * u_color;
	
	// Screen-door transparency
	if (gl_FragColor.a <= (bayer8(gl_FragCoord.xy) + 0.003921568627451)) {
		discard;
	}
	
	gl_FragColor.a = 1.;
	
	// Stencil
	gl_FragColor.rgb = mix(gl_FragColor.rgb, u_stencil.rgb, u_stencil.a);
}