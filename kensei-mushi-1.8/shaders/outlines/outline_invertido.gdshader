shader_type spatial;
render_mode cull_back, unshaded;

uniform float outline_thickness : hint_range(0.0, -1.0) = -0.0005;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, -1.0);

void vertex() {
    // Invertimos la normal restando el desplazamiento para que el borde crezca hacia adentro de la cueva
    VERTEX -= NORMAL * outline_thickness;
}

void fragment() {
    ALBEDO = outline_color.rgb;
}