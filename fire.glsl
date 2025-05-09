#iChannel0 "file://image.png"

/**
 * @function random
 * @description 生成一个基于输入二维向量的伪随机浮点数 (0.0 到 1.0)。
 * @param st 输入的二维向量坐标。
 * @returns 返回一个伪随机浮点数。
 */
float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

/**
 * @function valueNoise
 * @description 实现 Value Noise 算法，通过在网格顶点生成随机值并进行平滑插值来创建噪声。
 * @param st 输入的二维向量坐标。
 * @returns 返回插值后的噪声值。
 */
float valueNoise (vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f*f*(3.0-2.0*f); 

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

/**
 * @function fbm
 * @description 实现分形布朗运动 (Fractal Brownian Motion)，通过叠加多层不同频率和幅度的噪声来生成复杂纹理。
 * @param st 输入的二维向量坐标。
 * @returns 返回计算得到的 FBM 噪声值。
 */
float fbm (vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * valueNoise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

/**
 * @function sampleAlpha
 * @description 安全地采样纹理的 Alpha 值，处理边界情况。
 * @param uv 采样的 UV 坐标。
 * @returns 返回对应位置的 Alpha 值。
 */
float sampleAlpha(vec2 uv) {
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        return 0.0;
    }
    return texture(iChannel0, uv).a;
}

// 添加电流噪声函数
float electricNoise(vec2 uv, float time) {
    float noise = 0.0;
    float size = 20.0;
    float thickness = 1.5;
    
    for(float i = 1.0; i < 4.0; i++) {
        vec2 p = uv * size * i;
        p.x += time * 3.0 * i;
        p.y += sin(p.x * 0.5 + time * 2.0) * 1.5;
        
        float n = abs(fract(p.y * 0.5) - 0.5) * 2.0;
        n = pow(n, thickness);
        noise += n / i;
    }
    return noise;
}

/**
 * @function main
 * @description GLSL 片段着色器主函数，计算每个像素的最终颜色。
 */
void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 pixel = 1.0 / iResolution.xy;
    
    float lifetime = 2.0;
    float normalizedTime = mod(iTime, lifetime) / lifetime;
    float lifeProgress = 1.0;
    if (normalizedTime > 0.8) {
        lifeProgress = smoothstep(1.0, 0.0, (normalizedTime - 0.8) / 0.2);
    }
    
    vec4 originalImage = texture(iChannel0, uv);
    
    // 创建扩展的轮廓遮罩，增加范围
    float maskWidth = 50.0; // 增加遮罩宽度，使效果更大
    float shapeMask = 0.0;
    float totalWeight = 0.0;
    
    // 扩大采样范围
    for(float i = -maskWidth; i <= maskWidth; i++) {
        for(float j = -maskWidth; j <= maskWidth; j++) {
            vec2 offset = vec2(i, j) * pixel;
            float dist = length(offset);
            if(dist > maskWidth) continue;
            
            float weight = 1.0 - smoothstep(0.0, maskWidth, dist);
            float alpha = texture(iChannel0, uv + offset).a;
            shapeMask += alpha * weight;
            totalWeight += weight;
        }
    }
    
    // 标准化遮罩
    shapeMask = shapeMask / totalWeight;
    
    // 创建扩展的效果遮罩
    float expandedMask = smoothstep(0.05, 0.3, shapeMask); // 调整阈值使效果更大
    
    // 电流效果
    float time = iTime * 2.0;
    vec2 electricUV = uv;
    
    // 扩大电流效果范围
    float scale = 1.2; // 缩放因子
    electricUV = (electricUV - 0.5) / scale + 0.5;
    
    // 电流流动
    float angle = atan(electricUV.y - 0.5, electricUV.x - 0.5);
    float distortionStrength = 0.04; // 增加扭曲强度
    electricUV.x += sin(angle * 3.0 - time) * distortionStrength;
    electricUV.y += cos(angle * 3.0 - time) * distortionStrength;
    
    // 生成更大范围的电流
    float electric = electricNoise(electricUV * 0.8, time); // 降低频率使效果更大
    float electric2 = electricNoise(electricUV * 1.0 + vec2(time * 0.1), time * 1.5);
    
    // 电流颜色和强度
    vec4 electricColor = vec4(0.4, 0.8, 1.0, 1.0);
    float brightness = 4.0; // 增加亮度
    
    // 添加更多闪光点
    float sparks = step(0.96, electric2) * 2.5;
    
    // 组合电流效果
    float finalElectric = (electric * 0.6 + electric2 * 0.4 + sparks) * expandedMask;
    
    // 调整径向渐变
    float radialGradient = length((uv - 0.5) * scale);
    finalElectric *= (1.0 - radialGradient * 0.3); // 减少径向衰减
    
    // 颜色变化
    vec3 finalColor = electricColor.rgb;
    finalColor += vec3(0.2, 0.4, 0.6) * electric2;
    finalColor *= 1.0 + sparks * 0.5;
    
    // 创建背景效果层
    vec4 electricEffect = vec4(finalColor, 1.0) * finalElectric * brightness * lifeProgress;
    
    // 增强辉光
    float glow = smoothstep(0.0, 0.6, finalElectric);
    vec4 glowEffect = vec4(0.2, 0.4, 0.6, 1.0) * glow * lifeProgress * 1.5;
    
    // 分层混合：先渲染效果层，再叠加原始图像
    vec4 backgroundEffect = electricEffect + glowEffect;
    backgroundEffect.a *= 0.8; // 调整背景效果的透明度
    
    // 最终混合：背景效果 + 原始图像
    gl_FragColor = vec4(0.0);
    
    // 在有效果的地方显示背景效果
    if (backgroundEffect.a > 0.0) {
        gl_FragColor = backgroundEffect;
    }
    
    // 在有原始图像的地方显示原始图像
    if (originalImage.a > 0.0) {
        gl_FragColor = mix(gl_FragColor, originalImage, originalImage.a);
    }
}
