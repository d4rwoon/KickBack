shader_type canvas_item;

uniform float blur_miktari : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    // Bu kod resmi hafifçe kaydırarak bulanıkmış gibi gösterir
    vec4 renk = texture(TEXTURE, UV);
    renk += texture(TEXTURE, UV + vec2(blur_miktari * 0.01, 0.0));
    renk += texture(TEXTURE, UV - vec2(blur_miktari * 0.01, 0.0));
    renk += texture(TEXTURE, UV + vec2(0.0, blur_miktari * 0.01));
    renk += texture(TEXTURE, UV - vec2(0.0, blur_miktari * 0.01));
    COLOR = renk / 5.0;
}