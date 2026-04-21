shader_type canvas_item;

uniform vec2 resolution = vec2(600.0, 400.0);
uniform float firework_count: hint_range(1.0, 50.0, 1.0) = 1.0;
uniform float particle_count: hint_range(1.0, 50.0, 1.0) = 1.0;
uniform float size: hint_range(1.0, 10.0, 0.1) = 2.0;
uniform float sharpen: hint_range(1.0, 10.0, 0.1) = 1.5;
uniform float speed: hint_range(1.0, 10.0, 0.1) = 2.0;
uniform float gravity: hint_range(0.1, 2.0, 0.1) = 0.9;
uniform float lifetime: hint_range(1.0, 10.0, 0.1) = 7.0;

vec2 noise(vec2 uv) {
	uv = vec2(dot(uv, vec2(127.1,311.7)), dot(uv, vec2(269.5,183.3)));
	return fract(sin(uv) * 43758.5453123) * 0.5;
}

vec3 spark(vec2 uv, vec2 position, float index, float cycle) {
	vec2 direction = noise(vec2(0.1, 0.3) * index);

	if (mod(index, 2.0) == 0.0) {
		direction.x = -direction.x;
	}

	vec2 p = uv + position + direction * cycle;

	float dist = length(p);

	// solid circle (no glow, no transparency)
	float mask = step(dist, size * 0.009);

	// pastel palette (fixed soft colors)
	vec3 pastel_colors[5];
	pastel_colors[0] = vec3(1.0, 0.6, 0.7); // pink
	pastel_colors[1] = vec3(0.6, 0.8, 1.0); // light blue
	pastel_colors[2] = vec3(0.7, 1.0, 0.7); // light green
	pastel_colors[3] = vec3(1.0, 0.9, 0.6); // soft yellow
	pastel_colors[4] = vec3(0.8, 0.7, 1.0); // lavender

	vec3 col = pastel_colors[int(mod(index, 5.0))];

	return col * mask;
}

vec3 firework(vec2 uv, float index) {
	vec3 color = vec3(0.0);
	vec2 position = noise(vec2(0.2, 0.4) * index);
	if (mod(index, 2.0) == 0.0) {
		position.x = -position.x;
	}
	float cycle = mod(TIME * speed, lifetime * (1.0 + noise(vec2(0.1, 0.9) * index).x));
	for (float i = 1.0; i <= particle_count; i += 1.0) {
		color += spark(uv, position, i, cycle);
	}
	return color;
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	vec3 color = vec3(0.0);
	for (float i = 0.0; i < firework_count; i += 1.0) {
		color += firework(uv, i);
	}
	float alpha = clamp(length(color), 0.0, 1.0);
if (alpha < 0.01) {
	discard;
}
COLOR = vec4(color, alpha);
}
