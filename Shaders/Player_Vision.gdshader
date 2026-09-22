shader_type canvas_item;

// Koristimo backbuffer grupe da pročitamo šta je izabran CanvasGroup iscrtao pre poligona
uniform sampler2D current_screen_texture : hint_screen_texture;

void fragment() {
    // Ako poligon ima teksturu (ili boju), uzimamo njegovu alfu
    float poly_alpha = COLOR.a * texture(TEXTURE, UV).a;
    
    // Pročitamo boju mraka koja je do sada iscrtana u CanvasGroup-u
    vec4 group_color = texture(current_screen_texture, SCREEN_UV);
    
    // Oduzimamo alfu poligona od alfe mraka
    COLOR = vec4(group_color.rgb, group_color.a * (1.0 - poly_alpha));
}