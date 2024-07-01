shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;
uniform float crt_brightness: hint_range(0.0, 1.0) = 1.0;
uniform float crt_white_noise: hint_range(0.0, 1.0) = 0.0;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    float time = TIME;
    
    vec2 screen_uv = SCREEN_UV;
    vec3 color = texture(SCREEN_TEXTURE, screen_uv).rgb * (1.0 - crt_brightness * 0.5);
	color *= crt_brightness*5.0;
	
    vec2 noise_pixel = vec2(floor((screen_uv.x / SCREEN_PIXEL_SIZE.x) / 3.0) * 3.0, screen_uv.y) - sin(UV * PI);
    float white_noise = random(noise_pixel + vec2(sin(time + PI / 4.0), cos(time + PI / 8.0)));
    color = mix(color, vec3(white_noise), crt_white_noise);
   
    COLOR = vec4(color, 1.0);
}







