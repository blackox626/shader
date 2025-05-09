#iChannel0 "file://image/image.png"

// 生成柔和的噪声
float noise(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// 创建平滑的波动效果
float smoothNoise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// 检测边缘
float detectEdge(sampler2D tex, vec2 uv, vec2 pixel) {
    float alpha = texture(tex, uv).a;
    
    // 增加采样范围以获得更柔和的边缘
    float alphaN = texture(tex, uv + vec2(0.0, pixel.y * 3.0)).a;
    float alphaS = texture(tex, uv - vec2(0.0, pixel.y * 3.0)).a;
    float alphaE = texture(tex, uv + vec2(pixel.x * 3.0, 0.0)).a;
    float alphaW = texture(tex, uv - vec2(pixel.x * 3.0, 0.0)).a;
    
    // 添加对角线采样以获得更均匀的发光
    float alphaNE = texture(tex, uv + vec2(pixel.x * 2.0, pixel.y * 2.0)).a;
    float alphaSE = texture(tex, uv + vec2(pixel.x * 2.0, -pixel.y * 2.0)).a;
    float alphaNW = texture(tex, uv + vec2(-pixel.x * 2.0, pixel.y * 2.0)).a;
    float alphaSW = texture(tex, uv + vec2(-pixel.x * 2.0, -pixel.y * 2.0)).a;
    
    float edge = abs(alphaN - alpha) + abs(alphaS - alpha) + 
                 abs(alphaE - alpha) + abs(alphaW - alpha) +
                 abs(alphaNE - alpha) + abs(alphaSE - alpha) +
                 abs(alphaNW - alpha) + abs(alphaSW - alpha);
    return edge * 1.5; // 调整边缘强度
}

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;
    
    // 获取原始图像
    vec4 originalImage = texture(iChannel0, uv);
    
    // 检测边缘强度
    float edgeStrength = detectEdge(iChannel0, uv, pixel);
    
    // 创建光晕遮罩
    float glowRadius = 40.0;
    float glowStrength = 0.0;
    float totalWeight = 0.0;
    
    // 采样周围像素创建柔和光晕
    for(float i = -glowRadius; i <= glowRadius; i++) {
        for(float j = -glowRadius; j <= glowRadius; j++) {
            vec2 offset = vec2(i, j) * pixel;
            float dist = length(offset);
            if(dist > glowRadius * pixel.x) continue;
            
            vec2 sampleUV = uv + offset;
            float edge = detectEdge(iChannel0, sampleUV, pixel);
            // 使用更平滑的权重函数
            float weight = pow(1.0 - smoothstep(0.0, glowRadius * pixel.x, dist), 2.0);
            
            glowStrength += edge * weight;
            totalWeight += weight;
        }
    }
    
    // 标准化光晕强度
    glowStrength = glowStrength / totalWeight;
    
    // 创建多层次的动态波动效果
    float time = iTime * 0.4; // 降低动画速度
    vec2 noiseUV = uv * 2.5;
    float wave1 = smoothNoise(noiseUV + vec2(time * 0.2));
    float wave2 = smoothNoise(noiseUV * 1.5 + vec2(time * -0.15));
    float wave = mix(wave1, wave2, 0.5);
    wave = 0.6 + 0.4 * wave; // 减小波动幅度，增加基础亮度
    
    // 创建渐变的光晕颜色
    vec3 glowColor1 = vec3(0.8, 0.3, 0.9); // 较亮的品红色
    vec3 glowColor2 = vec3(0.5, 0.3, 1.0); // 较深的紫色
    vec3 glowColor3 = vec3(0.7, 0.4, 0.8); // 中间色
    
    vec3 glowColor = mix(
        mix(glowColor1, glowColor2, wave1),
        glowColor3,
        wave2
    );
    
    // 创建最终的光晕效果
    float finalGlow = smoothstep(0.0, 0.12, glowStrength) * wave;
    vec4 glowEffect = vec4(glowColor, 1.0) * finalGlow;
    
    // 混合原始图像和光晕效果
    gl_FragColor = originalImage;
    
    // 使用更平滑的混合
    float alpha = originalImage.a;
    float glowMask = (1.0 - alpha) * finalGlow;
    // 添加距离衰减
    float fadeEdge = 1.0 - smoothstep(0.0, 0.5, length(uv - vec2(0.5)));
    gl_FragColor = mix(gl_FragColor, glowEffect, glowMask * 1.8 * fadeEdge);
}
