// VERTEX ÜBERSHADER (PER-PIXEL)

#define MAX_BONES 64

/* ----------
   ATTRIBUTES
   ---------- */

attribute vec3 in_Position; // (x, y, z) 
attribute vec3 in_Normal; // (x, y, z)
attribute vec2 in_TextureCoord; // (u, v)
attribute vec2 in_TextureCoord2; // (u, v)
attribute vec4 in_Colour; // (r, g, b, a)
attribute vec4 in_BoneIndex; // (bone 1, bone 2, bone 3, bone 4)
attribute vec4 in_BoneWeight; // (weight 1, weight 2, weight 3, weight 4)

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
varying float v_rimlight;

/* --------
   UNIFORMS
   -------- */

uniform float u_time;

uniform vec4 u_wind; // strength, xyz

uniform vec2 u_material_scroll;
uniform vec3 u_material_wind; // waviness, lock bottom, speed

uniform int u_animated;
uniform vec4 u_bone_dq[2 * MAX_BONES];

//	Simplex 4D Noise 
//	by Ian McEwan, Ashima Arts
vec4 permute(vec4 x) {
	return mod(((x * 34.) + 1.) * x, 289.);
}

float permute(float x) {
	return floor(mod(((x * 34.) + 1.) * x, 289.));
}

vec4 taylor_inv_sqrt(vec4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

float taylor_inv_sqrt(float r) { 
	return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip) {
	const vec4 ones = vec4(1., 1., 1., -1.);
	vec4 p, s;
	
	p.xyz = floor(fract(vec3(j) * ip.xyz) * 7.) * ip.z - 1.;
	p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
	s = vec4(lessThan(p, vec4(0.)));
	p.xyz = p.xyz + (s.xyz * 2. - 1.) * s.www; 
	
	return p;
}

float snoise(vec4 v) {
	const vec2 C = vec2(0.138196601125010504,  // (5 - sqrt(5))/20  G4
						0.309016994374947451); // (sqrt(5) - 1)/4   F4
	
	// First corner
	vec4 i  = floor(v + dot(v, C.yyyy));
	vec4 x0 = v - i + dot(i, C.xxxx);
	
	// Other corners
	// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
	vec4 i0;
	vec3 is_x = step(x0.yzw, x0.xxx);
	vec3 is_yz = step(x0.zww, x0.yyz);
	
	i0.x = is_x.x + is_x.y + is_x.z;
	i0.yzw = 1. - is_x;
	i0.y += is_yz.x + is_yz.y;
	i0.zw += 1. - is_yz.xy;
	i0.z += is_yz.z;
	i0.w += 1. - is_yz.z;
	
	// i0 now contains the unique values 0,1,2,3 in each channel
	vec4 i3 = clamp(i0, 0., 1.);
	vec4 i2 = clamp(i0 - 1., 0., 1.);
	vec4 i1 = clamp(i0 - 2., 0., 1.);
	
	//x0 = x0 - 0.0 + 0.0 * C 
	
	vec4 x1 = x0 - i1 + 1. * C.xxxx;
	vec4 x2 = x0 - i2 + 2. * C.xxxx;
	vec4 x3 = x0 - i3 + 3. * C.xxxx;
	vec4 x4 = x0 - 1. + 4. * C.xxxx;
	
	// Permutations
	i = mod(i, 289.);
	
	float j0 = permute(permute(permute(permute(i.w) + i.z) + i.y) + i.x);
	vec4 j1 = permute(permute(permute(permute(
			  i.w + vec4(i1.w, i2.w, i3.w, 1.))
			+ i.z + vec4(i1.z, i2.z, i3.z, 1.))
			+ i.y + vec4(i1.y, i2.y, i3.y, 1.))
			+ i.x + vec4(i1.x, i2.x, i3.x, 1.));
	
	// Gradients
	// ( 7*7*6 points uniformly over a cube, mapped onto a 4-octahedron.)
	// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
	vec4 ip = vec4(1. / 294., 1. / 49., 1. / 7., 0.) ;
	vec4 p0 = grad4(j0, ip);
	vec4 p1 = grad4(j1.x, ip);
	vec4 p2 = grad4(j1.y, ip);
	vec4 p3 = grad4(j1.z, ip);
	vec4 p4 = grad4(j1.w, ip);
	
	// Normalise gradients
	vec4 norm = taylor_inv_sqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
	
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	p4 *= taylor_inv_sqrt(dot(p4,p4));
	
	// Mix contributions from the five corners
	vec3 m0 = max(0.6 - vec3(dot(x0, x0), dot(x1, x1), dot(x2, x2)), 0.);
	vec2 m1 = max(0.6 - vec2(dot(x3, x3), dot(x4, x4)), 0.);
	
	m0 = m0 * m0;
	m1 = m1 * m1;
	
	return 49. * (dot(m0 * m0, vec3(dot(p0, x0), dot(p1, x1), dot(p2, x2)))
			   + dot(m1 * m1, vec2(dot(p3, x3), dot(p4, x4))));
}

vec3 quat_rotate(vec4 q, vec3 v) {
	vec3 u = q.xyz;
	
	return (v + 2. * cross(u, cross(u, v) + q.w * v));
}

vec3 dq_transform(vec4 real, vec4 dual, vec3 v) {
	vec3 r3 = real.xyz;
	vec3 d3 = dual.xyz;
	
	return (quat_rotate(real, v) + 2. * (real.w * d3 - dual.w * r3 + cross(r3, d3)));
}

void main() {
	vec3 calc_position = in_Position;
	vec3 calc_normal = in_Normal;
	
	if (bool(u_animated)) {
		// Skeletal animation
		ivec4 i = ivec4(in_BoneIndex) * 2;
		ivec4 j = i + 1;
		
		vec4 real0 = u_bone_dq[i.x];
		vec4 real1 = u_bone_dq[i.y];
		vec4 real2 = u_bone_dq[i.z];
		vec4 real3 = u_bone_dq[i.w];
		
		vec4 dual0 = u_bone_dq[j.x];
		vec4 dual1 = u_bone_dq[j.y];
		vec4 dual2 = u_bone_dq[j.z];
		vec4 dual3 = u_bone_dq[j.w];
		
		if (dot(real0, real1) < 0.) {
			real1 *= -1.;
			dual1 *= -1.;
		}
		
		if (dot(real0, real2) < 0.) {
			real2 *= -1.;
			dual2 *= -1.;
		}
		
		if (dot(real0, real3) < 0.) {
			real3 *= -1.;
			dual3 *= -1.;
		}
		
		vec4 blend_real = real0 * in_BoneWeight.x + real1 * in_BoneWeight.y + real2 * in_BoneWeight.z + real3 * in_BoneWeight.w;
		vec4 blend_dual = dual0 * in_BoneWeight.x + dual1 * in_BoneWeight.y + dual2 * in_BoneWeight.z + dual3 * in_BoneWeight.w;
		float inv = 1. / length(blend_real);
		
		blend_real *= inv;
		blend_dual *= inv;
		calc_position = dq_transform(blend_real, blend_dual, calc_position);
		calc_normal = quat_rotate(blend_real, calc_normal);
	}
	
	// Vertex & normal transformation, rotation & translation
	mat4 world_matrix = gm_Matrices[MATRIX_WORLD];
	vec4 object_space_position_vec4 = world_matrix * vec4(calc_position, 1.);
	
	// Wind effect: Move vertices around using 4D simplex noise
	if (u_material_wind.x > 0.) {
		float wind_time = u_time * u_material_wind.z;
		float wind_strength = u_wind.x;
		float wind_weight = (1. - (u_material_wind.y * clamp(in_TextureCoord.y, 0., 1.))) * wind_strength * u_material_wind.x;
		float vx = in_Position.x;
		float vy = in_Position.y;
		float vz = in_Position.z;
		
		object_space_position_vec4.x += u_wind.y * snoise(vec4(vx, -vy, -vz, wind_time)) * wind_weight * min(length(world_matrix[0]), 1.);
		object_space_position_vec4.y += u_wind.z * snoise(vec4(-vx, vy, -vz, wind_time)) * wind_weight * min(length(world_matrix[1]), 1.);
		object_space_position_vec4.z += u_wind.w * snoise(vec4(-vx, -vy, vz, wind_time)) * wind_weight * min(length(world_matrix[2]), 1.);
	}
	
	mat4 view_matrix = gm_Matrices[MATRIX_VIEW];
	
	gl_Position = gm_Matrices[MATRIX_PROJECTION] * view_matrix * object_space_position_vec4;
	v_position = gl_Position.xyz;
	
	// Vertex color & lighting
	v_world_normal = normalize(mat3(world_matrix) * calc_normal);
	v_object_space_position = vec3(object_space_position_vec4);
	v_view_position = v_object_space_position + (view_matrix[3] * view_matrix).xyz;
	v_color = in_Colour;
	
	// Rimlight
	vec3 rim_n = normalize(mat3(view_matrix) * v_world_normal);
	vec3 rim_v = normalize(-vec3(view_matrix * object_space_position_vec4));
	
	v_rimlight = dot(rim_v, rim_n);
	
	// UVs
	v_texcoord = in_TextureCoord + (u_time * u_material_scroll);
	v_texcoord2 = in_TextureCoord2;
}