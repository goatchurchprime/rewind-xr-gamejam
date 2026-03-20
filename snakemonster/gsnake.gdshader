// NOTE: Shader automatically converted from Godot Engine 4.6.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D texture_albedo_sick : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D animtexture : repeat_disable;
uniform float sickfac = 0.0;

// UV.x is around, UV.y < 0.5 is along
uniform float snakerad = 0.05;
uniform float snakeradperi = 0.01;
uniform float timefac = 5.0;
uniform float perialongfac = 60.0;
uniform float texvtime = 0.0;
uniform float texutime = 0.0;
varying vec3 pnorm;
const float udelta = 0.01;
const float reelrad = 0.3;

vec3 texpos(float utime, float vtime) {
	if (utime < 0.0) {
		float th = -utime*16.0;
		vec3 p0 = texture(animtexture, vec2(0.0, vtime)).xyz;
		vec3 rv = vec3(-sin(th)*reelrad, (1.0-cos(th))*reelrad, 0.0);
		return p0 + rv;
	}
	vec3 p1 = texture(animtexture, vec2(utime, vtime)).xyz;
	return p1;
}
vec3 texvec(float utime, float vtime, vec3 p1) {
	return normalize(p1 - texpos(utime - udelta, vtime));
}
void vertex() {
	float utime = UV.y*2.0 - texutime;
	if (texvtime != 0.0) {
		if (utime <= texvtime*0.9)
			utime -= texvtime*0.9;
	}
	vec3 p1 = texpos(utime, texvtime);
	vec3 planenorm = texvec(utime, texvtime, p1);
	vec3 planex = normalize(vec3(planenorm.z, 0.0, -planenorm.x));
	vec3 planey = cross(planenorm, planex);
	pnorm = planex*VERTEX.x + planey*VERTEX.z;
	float rad = snakerad + snakeradperi*sin(TIME*timefac+UV.y*2.0*perialongfac);
	VERTEX = p1 - pnorm*rad;
}

void fragment() {
	vec2 base_uv = vec2(UV.x, fract(UV.y*10.0));
	vec4 albedo_tex = texture(texture_albedo, base_uv);
	if (sickfac != 0.0) {
		vec4 albedo_tex_sick = texture(texture_albedo_sick, base_uv);
		albedo_tex = mix(albedo_tex, albedo_tex_sick, sickfac);
	}
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	NORMAL = -pnorm;
}
