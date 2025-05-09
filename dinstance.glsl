
#iChannel0 "file://image.jpeg"

void main() {

    vec2 uv = gl_FragCoord.xy/iResolution.xy;
    vec3 col = vec3(0.0,0.0,0.0);
    
    vec2 tmpUV = 2.*uv- 1.;  //纹理坐标映射为[-1.0,1.0]

    tmpUV.x *= iResolution.x/iResolution.y; 

    float dis = distance(tmpUV,vec2(0.0,0.0));

    if(dis<0.5)
        col = texture(iChannel0,uv).rgb;

    // if(length(tmpUV) - 0.5*abs(cos(iTime)) < .0) 
    //     col = texture(iChannel0,uv).rgb;

    gl_FragColor = vec4(col,1.0);
}