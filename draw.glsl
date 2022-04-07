vec3 drawAxis(vec2 uv)
{
    float seperatorWidth = 0.005;
    vec3 ret = vec3(0.0,0.0,0.0);
    if(abs(uv.x)<seperatorWidth )
        ret = vec3(1.0,0.0,0.0);
    if(abs(uv.y)<seperatorWidth )
        ret = vec3(0.0,1.0,0.0);
    return ret;
}

vec3 drawFunc(vec2 uv)
{
    vec3 ret = vec3(0.0,0.0,0.0);
    //func sinx
    float seperatorWidth = 0.05;
    float y = sin(uv.x);
    if(uv.y<y+seperatorWidth&&uv.y>y-seperatorWidth)
        ret = vec3(1.0,1.0,0.0);
    return ret;
}


vec3 drawFunc2(vec2 uv)
{
    vec3 ret = vec3(0.0,0.0,0.0);
    //func cosx
    float seperatorWidth = 0.05;
    float y = cos(uv.x);
    if(uv.y<y+seperatorWidth&&uv.y>y-seperatorWidth)
        ret = vec3(1.0,0.0,0.0);
    return ret;
}

vec3 drawCircle(vec2 uv,float radius)
{
    vec3 ret = vec3(0.0,0.0,0.0);
    if(length(uv)>radius-0.1 && length(uv)<radius+0.1)
        ret = vec3(0.0,0.0,1.0);
    return ret;
}


void main() {

    vec2 pos = (2.0*gl_FragCoord.xy - iResolution.xy)/min(iResolution.x,iResolution.y);

    // vec2 uv = gl_FragCoord.xy/iResolution.xy;
    // vec2 pos = 2.0*uv- 1.0;  //纹理坐标映射为[-1.0,1.0]
    // pos.x *= iResolution.x/iResolution.y; 

    /// 推导过程    

    // vec2 pos = (2.0 * gl_FragCoord.xy/iResolution.xy - 1.) * vec2(iResolution.x/iResolution.y,1.0);
    // pos = ((2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.xy) * vec2(iResolution.x/iResolution.y,1.0);
    // pos = (2.0 * gl_FragCoord.xy - iResolution.xy)  * vec2(iResolution.x/iResolution.y,1.0) / iResolution.xy;
    // pos = (2.0 * gl_FragCoord.xy - iResolution.xy)  * vec2(iResolution.x,iResolution.y) / iResolution.y / iResolution.xy;
    // pos = (2.0 * gl_FragCoord.xy - iResolution.xy)  * iResolution.xy / iResolution.y / iResolution.xy;
    // pos = (2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.y;


    gl_FragColor = vec4(drawAxis(pos)+drawFunc2(pos*10.0)+drawFunc(pos*10.0)+drawCircle(pos*10.0,2.5),1.0);
}