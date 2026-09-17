#version 330 core

out vec4 out_color;

uniform vec2 size;
uniform float time;
uniform mat4 view;

const float epsilon = 0.0001;

struct ray_hit {
	bool has_hit;
	vec3 pos;
	vec3 normal;
	vec4 color;
};

ray_hit trace(vec3 ray_pos, vec3 ray_dir) 
{
    ray_hit result;
    result.has_hit = false;
    result.pos = ray_pos;
    result.normal = vec3(0);
    result.color = vec4(0, 0, 0, 1);

    float closest_t = 1e20;

    vec3 sphere_pos = vec3(0, 0, 0);
    float sphere_radius = 1.0f;

    float sphere_t_proj = dot(sphere_pos - ray_pos, ray_dir) / dot(ray_dir, ray_dir);
    vec3 sphere_proj_pt = ray_pos + sphere_t_proj * ray_dir;
    float d = length(sphere_proj_pt - sphere_pos);

    if (d < sphere_radius) {
        float th = sqrt(sphere_radius * sphere_radius - d * d);
        float sphere_t0 = sphere_t_proj - th;
        float sphere_t1 = sphere_t_proj + th;

        float sphere_t = (sphere_t0 > epsilon) ? sphere_t0 : sphere_t1;
        if (sphere_t > epsilon && sphere_t < closest_t) {
            closest_t = sphere_t;
            result.has_hit = true;
            result.pos = ray_pos + sphere_t * ray_dir;
            result.normal = normalize(result.pos - sphere_pos);
            result.color = vec4(1, 0, 0, 1); // Red Sphere
        }
    }

    if (abs(ray_dir.y) > epsilon) { 
        float plane_t = (-1.f - ray_pos.y) / ray_dir.y;
        if (plane_t > epsilon && plane_t < closest_t) {
            closest_t = plane_t;
            result.has_hit = true;
            result.pos = ray_pos + plane_t * ray_dir;
            result.normal = vec3(0, 1, 0);

            if (mod(floor(2.0 * result.pos.x) + floor(result.pos.z), 2.0) < 0.5) {
                result.color = vec4(vec3(0.5), 1.0);
            } else {
                result.color = vec4(vec3(0.6), 1.0);
            }
        }
    }

    return result;
}

void
main(void)
{
    float fov = 45.0;
    vec2 xy = gl_FragCoord.xy - size / 2.0;
    float z = size.y / tan(radians(fov) / 2.0);
    vec3 eye = (view * vec4(vec3(0), 1)).xyz;
    vec3 dir = (view * vec4(normalize(vec3(xy, -z)), 0)).xyz;

	ray_hit hit = trace(eye, dir);
	if (hit.has_hit) {
		vec3 to_light = normalize(vec3(1.0, 1.0, 1.0));
		float diffuse = max(dot(hit.normal, to_light), 0.0);
		if (diffuse > 0.0) {
			ray_hit light_hit = trace(hit.pos + epsilon * hit.normal, to_light);
			if (light_hit.has_hit) {
				diffuse *= 0.2;
			}
		} else {
			diffuse *= 0.2;
		}

		vec3 ambient = hit.color.rgb * 0.1; 
		out_color = vec4(ambient + (hit.color.rgb * diffuse), 1.0);
	} else {
		out_color = vec4(0.2, 0.4, 0.6, 1.0); 
	}
}
