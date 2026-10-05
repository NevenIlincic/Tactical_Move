shader_type canvas_item;

// Uzima uslikanu pozadinu iz BackBufferCopy-ja (originalni TileMap pre CanvasModulate-a)
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
    // Uzimamo originalne piksele sa ekrana napravljene pre nego što je primenjen mrak
    vec4 originalna_boja = texture(screen_texture, SCREEN_UV);
    
    // Prikazujemo originalni TileMap (sam poligon je nevidljiv, vidi se samo podloga)
    COLOR = originalna_boja;
}