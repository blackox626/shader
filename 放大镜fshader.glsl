precision highp float;
// uniform vec2 iResolution;
// uniform float offsetY;
// uniform float offsetX;
// uniform float size;
// uniform float intensity;
// uniform float scale;
// varying highp vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;
// uniform sampler2D inputImageTexture3;

#iChannel0 "file://image/image.jpeg"
#iChannel1 "file://image/materialap-5ebd0000017b299d61670a20e47a-unadjust_512_512.png"

#iUniform float offsetY = 0.5
#iUniform float offsetX = 0.5
#iUniform float size = 0.3
#iUniform float scale = 0.5
#iUniform float intensity = 1.0


vec4 lm_take_effect_filter(sampler2D filterTex,vec4 inputColor,float intensity)
{

  highp vec4 textureColor = inputColor;
     
     highp float blueColor = textureColor.b * 63.0;
     
     highp vec2 quad1;
     quad1.y = floor(floor(blueColor) / 8.0);
     quad1.x = floor(blueColor) - (quad1.y * 8.0);
     
     highp vec2 quad2;
     quad2.y = floor(ceil(blueColor) / 8.0);
     quad2.x = ceil(blueColor) - (quad2.y * 8.0);
     
     highp vec2 texPos1;
     texPos1.x = (quad1.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
     texPos1.y = 1. - ((quad1.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g));
     
     highp vec2 texPos2;
     texPos2.x = (quad2.x * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.r);
     texPos2.y = 1. - ((quad2.y * 0.125) + 0.5/512.0 + ((0.125 - 1.0/512.0) * textureColor.g));
     
     lowp vec4 newColor1 = texture(filterTex, texPos1);
     lowp vec4 newColor2 = texture(filterTex, texPos2);
     
     lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
     newColor = mix(textureColor, vec4(newColor.rgb, textureColor.w), intensity);
     
    return newColor;
}

void main() {

    float size2 = size * 0.5;

    vec2 mouse_uv = vec2(offsetX,offsetY) - 0.5;

    float line = 0.002; 
    vec2 uv0 = gl_FragCoord.xy/iResolution.xy;

    // float interpolatedValue = mix(0., 1., uv.y);
    // vec3 col = vec3(interpolatedValue);
    // gl_FragColor = vec4(col,1.0);
    vec2 uv = uv0 - 0.5;
    if(iResolution.x<iResolution.y)
     uv.x *=iResolution.x/iResolution.y;
    else
     uv.y *=iResolution.y/iResolution.x;

    float mouse_dist = length(uv-mouse_uv);
    // Draw the texture
	  vec4 Col1 = texture2D(iChannel0, uv0);
  
    // Draw the outline of the glass
    //Draw a zoomed-in version of the texture

    /// 推到过程
    /// vec2 newUV0 
    /// (newUV0 - vec2(offsetX,offsetY)) * (1 + scale) = uv0 - vec2(offsetX,offsetY)
    /// newUV0 = (uv0 - vec2(offsetX,offsetY)) / (1.0 + scale) + vec2(offsetX,offsetY) 

    vec2 newUV0 = (uv0 - vec2(offsetX,offsetY)) / (1.0 + scale) + vec2(offsetX,offsetY);

    vec4 curColor = texture(iChannel0, newUV0);
    vec4 resultColorout = lm_take_effect_filter(iChannel1,Col1,intensity);
    // vec4 Col2=texture2D(outsideImageTexture, (uv0 + mouse_uv) / 2.0);
    gl_FragColor = mix(curColor,resultColorout, mouse_dist > size2 ? 1. : 0.);
    // gl_FragColor = mix(curColor,Col1,smoothstep(size-0.001,size+0.001,mouse_dist));
    // float circleW=line;
    float circle=smoothstep(size2-line,size2,mouse_dist)*smoothstep(size2+line,size2,mouse_dist);
    // circle*=circle;
    gl_FragColor = mix(gl_FragColor,vec4(1.0),circle);
    gl_FragColor.a = Col1.a;

    // gl_FragColor = curColor;
}