shader_type canvas_item;

uniform float highlight_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 white = vec4(1.0, 1.0, 1.0, tex_color.a);
    COLOR = mix(tex_color, white, highlight_amount);
}
