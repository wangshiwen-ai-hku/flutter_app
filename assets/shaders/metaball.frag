
#include <flutter/runtime_effect.glsl>

uniform sampler2D uTexture;
out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / textureSize(uTexture, 0);
    vec4 color = texture(uTexture, uv);

    if (color.a > 0.5) {
        fragColor = vec4(color.rgb, 1.0);
    } else {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
