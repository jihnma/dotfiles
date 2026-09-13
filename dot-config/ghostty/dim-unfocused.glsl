// Fade a surface toward its own background colour while it is unfocused.
//
// Ghostty already does this for unfocused splits via unfocused-split-opacity,
// but that never applies to separate windows. iFocus is the surface's focus
// state, so the same effect can be had per window.
//
// Fading toward iBackgroundColor rather than toward black keeps this correct
// under both halves of a light/dark theme. FADE mirrors ghostty's own default
// for splits: unfocused-split-opacity = 0.7.

const float FADE = 0.3;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 color = texture(iChannel0, fragCoord / iResolution.xy);

    if (iFocus > 0) {
        fragColor = color;
        return;
    }

    fragColor = vec4(mix(color.rgb, iBackgroundColor, FADE), color.a);
}
