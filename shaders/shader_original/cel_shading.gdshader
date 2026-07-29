shader_type spatial;
render_mode specular_toon, blend_mix, depth_draw_opaque, cull_back;

uniform vec4 albedo : source_color = vec4(1.0);
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise_texture : filter_nearest, repeat_enable;
uniform float noise_scale = 5.0;

uniform float cutoff_1 : hint_range(0.0, 1.0) = 0.6;
uniform float cutoff_2 : hint_range(0.0, 1.0) = 0.3;

uniform vec4 color_luz : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_medio : source_color = vec4(0.6, 0.6, 0.7, 1.0);
uniform vec4 color_sombra : source_color = vec4(0.2, 0.2, 0.3, 1.0);

varying vec2 vertex_uv;

void vertex() {
    vertex_uv = UV;
}

void fragment() {
    // 1. Lees el color de la textura (incluyendo el canal alfa)
    vec4 tex = texture(texture_albedo, vertex_uv);
    
    // 2. Aplicas el color base (multiplicado por el albedo uniforme)
    ALBEDO = albedo.rgb * tex.rgb;
    
    // 3. ¡CLAVE! Asignas el canal alfa de la textura a la variable ALPHA.
    // Esto le dice a Godot: "Si la textura es transparente aquí, no dibujes nada".
    ALPHA = tex.a;
}

void light() {
    float NdotL = dot(NORMAL, LIGHT);
    float noise = texture(noise_texture, vertex_uv * noise_scale).r;
    
    float adj_cut1 = cutoff_1 + (noise - 0.5) * 0.25;
    float adj_cut2 = cutoff_2 + (noise - 0.5) * 0.25;
    
    vec3 final_shading = color_sombra.rgb;
    if (NdotL > adj_cut1) {
        final_shading = color_luz.rgb;
    } else if (NdotL > adj_cut2) {
        final_shading = color_medio.rgb;
    }
    
    vec4 tex = texture(texture_albedo, vertex_uv);
    DIFFUSE_LIGHT = LIGHT_COLOR * final_shading * ATTENUATION * tex.rgb;
}
