#iChannel0 "file://yaoqi/image1.png"

const float alphaThreshold = 0.85;
 
void main() {
 
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
 
    // 从 iChannel0 (你的输入图片) 采样像素颜色
    vec4 originalPixel = texture2D(iChannel0, uv);

    // 基于 Alpha 通道创建辉光来源遮罩：
    // 如果 originalPixel.a (alpha值) 大于 alphaThreshold，则 glowSourceMask 为 1.0 (白色)
    // 否则为 0.0 (黑色)
    // float glowSourceMask = step(alphaThreshold, originalPixel.a);

    // 输出灰度图:
    // R, G, B 通道都设置为 glowSourceMask，Alpha 设置为 1.0
    gl_FragColor = vec4(vec3(originalPixel.a), 1.0);
}

