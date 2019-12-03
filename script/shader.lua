
local ejoy2d = require "ejoy2d"

local function shadow_shader()
	ejoy2d.define_shader
{
	name="SHADOW",
	fs=[[
varying vec2 v_texcoord;
varying vec4 v_position;
varying vec4 v_color;
varying vec4 v_additive;
uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float light_range;
uniform float light_smooth;
uniform vec3 light_position;

void main() {
	vec3 lightColor = vec3(1,1,1);
	vec4 pixel;
	vec2 screenSize = vec2(1024, 768);
	vec2 dim = vec2(1, screenSize.y / screenSize.x);
	vec2 lightGlow = vec2(0.9, 1.8);
	bool invert_normal = false;

	vec3 pixel_coords = vec3(v_position * dim, 1.0);

	float dist = distance(light_position, pixel_coords);
	if (dist > light_range) {
		gl_FragColor = vec4(0,0,0,0);
	} else {
		vec4 normalColor = texture2D(texture1, v_texcoord);

    	float att = clamp((1.0 - dist / light_range) / light_smooth, 0.0, 1.0);
		pixel = vec4(0.0, 0.0, 0.0, 1.0);

		if (normalColor.a<=0) {
			if (lightGlow.x < 1.0 && lightGlow.y > 0.0) {
				pixel.rgb = clamp(lightColor * pow(att, light_smooth) + pow(smoothstep(lightGlow.x, 1.0, att), light_smooth) * lightGlow.y, 0.0, 1.0);
			} else {
				pixel.rgb = lightColor * pow(att, light_smooth);
			}
		} else {
			vec3 normal = normalize(vec3(normalColor.r,invert_normal ? 1.0 - normalColor.g : normalColor.g, normalColor.b) * 2.0 - 1.0);
			vec3 dir = vec3((light_position.xy - pixel_coords.xy) * dim, 0.2);
			dir.x *= dim.x / dim.y;
			float dot_val = max(dot(normalize(normal), normalize(dir)), 0.0);
			vec3 diff = lightColor * pow(dot_val,2) * 1.1;
			pixel = vec4(diff * att, 1.0);
		}

		vec4 tmp = texture2D(texture0, v_texcoord);
		gl_FragColor.xyz = tmp.xyz * v_color.xyz;
		gl_FragColor.w = tmp.w;
		gl_FragColor *= v_color.w;
		gl_FragColor.xyz += v_additive.xyz * tmp.w;
		gl_FragColor.rgb = gl_FragColor.rgb * pixel.rgb;
	}
}
]],
	vs=[[
attribute vec4 position;
attribute vec2 texcoord;
attribute vec4 color;
attribute vec4 additive;

varying vec2 v_texcoord;
varying vec4 v_position;
varying vec4 v_color;
varying vec4 v_additive;

void main() {
	gl_Position = position + vec4(-1.0,1.0,0,0);
	v_texcoord = texcoord;
	v_position = gl_Position;
	v_color = color;
	v_additive = additive;
}
]],
	uniform = {
		{
			name = "light_position",
			type = "float3",
		},
		{
			name = "light_range",
			type = "float",
		},
		{
			name = "light_smooth",
			type = "float",
		}
	},
	texture={
		"texture0",
		"texture1"
	}
}
end

local M = {}

function M:init()
	shadow_shader()
end

return M
