#iChannel0 "file://image.png"

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec4 originalImage = texture(iChannel0, uv);
    gl_FragColor = originalImage;
}
