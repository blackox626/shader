// precision highp float;
// varying highp vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;
// uniform sampler2D inputImageTexture3;
// uniform vec2 iResolution;


#iUniform float iReverse = 0.

#iUniform float _X = 0.5
#iUniform float _Y = 0.5
#iUniform float _S = 0.25
#iUniform float _A = 0.
#iUniform float _F = 0.00

#iUniform float iPlatform_iOS = 1.0

const float PI = 3.1415926;

#iChannel0 "file://followw813654.jpeg"
#iChannel1 "file://mask.png"

vec2 rotation(vec2 uv, float angle, float ratio)
{
    vec2 center = vec2(0.5, 0.5);
    mat2 zRotation = mat2(cos(angle), sin(angle), -sin(angle) * ratio, cos(angle) * ratio);
    vec2 centeredPoint = uv - center;
    vec2 newUv = zRotation * centeredPoint;
    return vec2(newUv.x, newUv.y / ratio) + center;
}


vec2 scale(vec2 uv, vec2 scale)
{
    vec2 newPos = vec2(0.5) + (uv - vec2(0.5)) / scale;
    return newPos;
}


vec2 offset(vec2 uv, vec2 offset)
{
    return uv + offset;
}


void main()
{
    highp vec2 textureCoordinate = gl_FragCoord.xy/iResolution.xy;

    float radio = iResolution.x / iResolution.y;
    bool ls = (radio > 1.0);
    vec4 base = texture(iChannel0, textureCoordinate);    

    float _Radio = 1.0;
    float _Scale = _S * 5.;
    _Scale = ls ? _Scale / radio : _Scale;
    float _Angle = 360. * PI / 180. * _A;
    vec2 _Offset = vec2(_X * 2.0 - 1.0, (_Y * 2.0 - 1.0)); 

    vec2 newUV = offset(textureCoordinate, vec2(-_Offset.x, _Offset.y));
    newUV = scale(newUV, vec2(1. * _Scale, radio * _Scale));
    newUV = rotation(newUV, _Angle, _Radio);
    newUV.y = (iPlatform_iOS == 1.) ? newUV.y : (1. - newUV.y);
    vec4 mask = texture(iChannel1, newUV) * step(newUV.x, 1.) * step(newUV.y, 1.) * step(0., newUV.x) * step(0., newUV.y);

    vec2 col = mask.rg;
    // 怎么理解 ？  根据 mask图的 作图颜色搭配 动态调整
    // 第1层c00d00 第2层800000~80ff00 第3层400000~40ff00 第4层000000~00ff00
    // R * 4 + G 算下来 从 0 到 781 
    // 781 = 12 * 16 * 4 + 13
    float alpha = (col.r * 4.0 * 256.0 + col.g  * 255.0) / 781.0;
    alpha = smoothstep(0.49 - abs(sin(iTime/2.)), 0.51 + abs(sin(iTime/2.)), alpha);
    if (iReverse > .5) {
        alpha = 1.0 - alpha;
    }
    gl_FragColor = mix(vec4(0, 0, 0, alpha), base, alpha);
}
