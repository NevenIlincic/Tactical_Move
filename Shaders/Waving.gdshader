shader_type canvas_item;

// Omogućava čitanje ekrana iza ovog objekta
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Parametri za talasanje
uniform float amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float frequency : hint_range(0.0, 50.0) = 15.0;
uniform float speed : hint_range(0.0, 10.0) = 3.0;

// Opciono: nijansa boje vode/stakla (npr. plavkasta)
uniform vec4 tint_color : source_color = vec4(0.0, 0.4, 0.8, 0.2);

void fragment() {
    // Uzimamo koordinate ekrana (SCREEN_UV)
    vec2 cPos = SCREEN_UV;
    
    // Izračunavamo deformaciju (talas)
    float wave = sin(UV.y * frequency + TIME * speed) * amplitude;
    
    // Pomera se SCREEN_UV na X osi
    cPos.x += wave;
    
    // Uzimamo sliku iz pozadine sa izmenjenim koordinatama
    vec4 screen_color = texture(screen_texture, cPos);
    
	COLOR.rgb = mix(screen_color.rgb, tint_color.rgb, tint_color.a);
	COLOR.a = screen_color.a;
    // Mešamo sliku pozadine sa blagom nijansom boje
}