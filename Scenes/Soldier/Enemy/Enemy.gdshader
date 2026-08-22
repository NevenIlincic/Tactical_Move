shader_type canvas_item;

void fragment() {
    // Čitamo izolovanu teksturu unutar CanvasGroup-a
    vec4 group_color = texture(TEXTURE, UV);
    
    // Čitamo mračnu pozadinu ekrana
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Zadržavamo originalnu boju ekrana, ali joj jačinu (alfa kanal) 
    // diktiramo isključivo preko oblika našeg Polygon2D-a
    COLOR = vec4(screen_color.rgb, group_color.a);
}