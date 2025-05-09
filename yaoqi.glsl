#iChannel0 "file://image.png"

// 妖气/能量效果 Shader
#define NUM_OCTAVES 5

float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
    vec2 ip = floor(p);
    vec2 u = fract(p);
    u = u*u*(3.0-2.0*u);
    
    float res = mix(
        mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
        mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
    return res*res;
}

float fbm(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100);
    // 增加旋转动态性
    float angle = sin(iTime * 0.3) * 0.2 + 0.5;
    mat2 rot = mat2(cos(angle), sin(angle), -sin(angle), cos(angle));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = gl_FragCoord.xy/iResolution.xy;
    
    // 获取原始图像
    vec4 originalImage = texture(iChannel0, uv);
    
    // 计算图像的亮度，使用alpha通道来判断人像区域
    float brightness = originalImage.a;
    
    // 调整UV坐标
    vec2 energyUV = uv;
    energyUV.x = energyUV.x * 2.0 - 1.0;
    energyUV.y = 1.0 - energyUV.y;
    
    // 添加更剧烈的扭曲效果
    float distortionTime = iTime * 0.5;
    energyUV.x += sin(energyUV.y * 4.0 + distortionTime) * 0.2;
    energyUV.y += cos(energyUV.x * 3.0 + distortionTime) * 0.1;
    
    // 基础形状
    vec2 shapeScale = vec2(0.6, 1.2);
    float shape = 1.0 - length(energyUV * shapeScale);
    
    // 添加波动效果
    shape *= 1.0 + sin(iTime * 4.0 + energyUV.y * 5.0) * 0.2;
    
    // 添加多层扭曲
    vec2 q = vec2(0);
    q.x = fbm(energyUV + distortionTime * 0.2);
    q.y = fbm(energyUV + q.x + vec2(5.2) + distortionTime * 0.1);
    
    vec2 r = vec2(0);
    r.x = fbm(energyUV + q + vec2(1.7, 9.2) + distortionTime * 0.15);
    r.y = fbm(energyUV + r + vec2(8.3, 2.8) + distortionTime * 0.126);
    
    // 能量效果
    float f = fbm(energyUV + r);
    
    // 基础强度
    float intensity = pow(f * shape, 2.0) * 3.0;
    
    // 创建妖气/能量效果的颜色
    vec3 energyCol = vec3(0);
    
    // 主要的能量色调
    vec3 primaryColor = mix(
        vec3(0.6, 0.2, 1.0),    // 紫色
        vec3(0.2, 0.5, 1.0),    // 蓝色
        sin(iTime * 0.5) * 0.5 + 0.5
    );
    
    // 次要的能量色调
    vec3 secondaryColor = mix(
        vec3(1.0, 0.3, 0.9),    // 粉紫色
        vec3(0.3, 0.8, 1.0),    // 亮蓝色
        cos(iTime * 0.3) * 0.5 + 0.5
    );
    
    // 混合能量颜色
    energyCol = mix(vec3(0.0), primaryColor, intensity);
    energyCol = mix(energyCol, secondaryColor, pow(length(q), 2.0));
    
    // 添加电光效果
    float lightning = pow(sin(iTime * 10.0 + energyUV.y * 20.0) * 0.5 + 0.5, 5.0);
    energyCol += vec3(0.8, 0.9, 1.0) * lightning * shape;
    
    // 添加边缘光晕
    float glow = pow(shape, 2.0) * 0.5;
    energyCol += primaryColor * glow;
    
    // 能量波动
    float wave = sin(energyUV.y * 20.0 + iTime * 5.0) * 0.5 + 0.5;
    energyCol *= 1.0 + wave * 0.3;
    
    // 调整最终亮度
    float finalBrightness = shape * 2.0;
    finalBrightness *= 1.0 + sin(iTime * 5.0) * 0.2;
    energyCol *= finalBrightness;
    
    // 计算alpha
    float energyAlpha = clamp(finalBrightness * 1.5, 0.0, 1.0);
    
    // 根据原图调整混合
    float blendFactor = 1.0 - brightness;
    
    // 混合原图和能量效果
    vec3 finalColor = mix(originalImage.rgb, 
                         energyCol + originalImage.rgb * 0.3, 
                         energyAlpha * blendFactor * 0.85);
    
    // 添加整体光晕
    finalColor += energyCol * 0.2;
    
    // 颜色校正
    finalColor = pow(finalColor, vec3(0.85));
    
    gl_FragColor = vec4(finalColor, originalImage.a);
}
