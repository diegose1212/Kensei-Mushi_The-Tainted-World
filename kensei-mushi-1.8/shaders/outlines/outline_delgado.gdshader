shader_type spatial;
render_mode cull_front, unshaded;

uniform float outline_thickness : hint_range(0.0, 1.0) = 0.0005;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
    // Escalamos directamente desde el vértice usando la normal
    VERTEX += NORMAL * outline_thickness;
}

void fragment() {
    ALBEDO = outline_color.rgb;
}