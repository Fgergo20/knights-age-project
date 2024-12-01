shader_type canvas_item;

// Buborék színe (RGBA formátum)
uniform vec4 bubble_color = vec4(0.8, 0.9, 1.0, 1.0);
// Mana sáv alap színe
uniform vec4 bar_color = vec4(0.0, 0.0, 0.5, 1.0);
// Buborék mozgásának sebessége
uniform float bubble_speed = 1.0;
// Buborék mérete
uniform float bubble_size = 0.1;

void fragment() {
    vec2 uv = UV; // UV koordináták használata a megfelelő skálázáshoz

    // Idő alapú mozgás
    float time = TIME * bubble_speed;

    // Buborékok generálása
    float bubble1 = sin(uv.x * 10.0 + time) * cos(uv.y * 10.0 + time);
    float bubble2 = sin((uv.x + time) * 15.0) * cos((uv.y - time) * 20.0);

    // Összevonjuk a buborékok hatását
    float bubble_effect = bubble1 + bubble2;

    // Buborék hatás kisimítása és méretezése
    float bubble_mask = smoothstep(0.5 - bubble_size, 0.5, abs(bubble_effect));

    // Színek keverése
    vec4 final_color = mix(bar_color, bubble_color, bubble_mask);

    COLOR = final_color;
}
