// precision highp float;
// varying highp vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;
// uniform vec2 iResolution;


// uniform float iReverse;
// uniform float iOpacity;

// uniform float _X;
// uniform float _Y;
// uniform float _W;
// uniform float _H;
// uniform float _A;
// uniform float _C;
// uniform float _F;

#iUniform float _X = 0.5
#iUniform float _Y = 0.5
#iUniform float _W = 0.5
#iUniform float _H = 0.5

#iUniform float _A = 0.
#iUniform float _C = 0.
#iUniform float _F = 0.0

uniform float iPlatform_iOS;

const float PI = 3.141592654;

#iChannel0 "file://followw813654.jpeg"

void main(void) 
{   
    vec2 u_center = vec2(_X, _Y);
    vec2 u_size = vec2(_W, _H) * .5;
    float u_rotate = 360. * PI / 180. * _A;
    float u_roundCorner = _C;
    float u_diff = _F;

    float u_aspect = iResolution.x / iResolution.y;;
    vec2 texcoord0 = gl_FragCoord.xy/iResolution.xy;
    vec2 sampIn = vec2((texcoord0.x - u_center.x) * u_aspect, texcoord0.y - u_center.y);
    sampIn = vec2(cos(u_rotate) * sampIn.x - sin(u_rotate) * sampIn.y, sin(u_rotate) * sampIn.x + cos(u_rotate) * sampIn.y);

    vec2 u_rightTop = vec2(u_size.x * u_aspect, u_size.y);
    float u_circleRadius = .0;
    if (u_size.x * u_aspect >= u_size.y) {
        u_circleRadius = u_size.y * u_roundCorner;
    } else {
        u_circleRadius = u_size.x * u_aspect * u_roundCorner;
    }

    vec2 u_circleCenter = vec2(u_rightTop.x - u_circleRadius, u_rightTop.y - u_circleRadius);

    vec2 samp = abs(sampIn);
    float alpha = 0.0;
    if (samp.y * u_circleCenter.x >= u_rightTop.y * samp.x)
    {
        alpha = samp.y / u_size.y;
    }
    else if (samp.y * u_rightTop.x <= u_circleCenter.y * samp.x)
    {
        alpha = samp.x / (u_aspect * u_size.x);
    }
    else
    {
        /// 懵逼了 ？？？ 
        float a = dot(u_circleCenter, u_circleCenter) - u_circleRadius * u_circleRadius;
        float b = -2.0 * dot(samp, u_circleCenter);
        float c = dot(samp, samp);
        if (abs(a) < 0.00000001)
        {
            if (abs(b) < 0.00000001)
            {
                alpha = 100.0;
            }
            else
            {
                alpha = -c / b;
            }
        }
        else
        {
            alpha = (-b - sqrt(b * b - 4.0 * a * c)) / (2.0 * a);
        }
    }
    alpha = clamp(smoothstep(0.995 - u_diff, 1.005 + u_diff, alpha), 0.0, 1.0);
    gl_FragColor = texture(iChannel0, texcoord0) * (1. - alpha);
}