#iChannel0 "file://yaoqi/image1.png"
// #iChannel1 "file://yaoqi/pass-1.glsl"
#iChannel1 "file://yaoqi/mask_from_alpha_rgba.png"

void main() {
 
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
 
    vec4 color1 = texture2D(iChannel0, uv);      //current frame
    vec2 uv2 = uv;
    uv2.x -= 0.05 * sin(iTime);
    uv2.y += 0.03 * cos(iTime);
    vec4 color2 = texture2D(iChannel0, uv2);
 
    vec4 maskColor = texture2D(iChannel1,uv);

    vec3 grayW = vec3(0.299,0.587,0.114);
 
    float motion = abs(dot(color1.rgb,grayW)-dot(color2.rgb,grayW));
    vec3 color = vec3(pow(motion,1.2)*3.0);
 
    //筛选运动边缘，使其产生烟雾
    // if(motion > 0.5)
    //     maskColor.a = 1.0;

	vec4 resultColor = vec4(color1.rgb*color*pow(clamp(maskColor.r*5.0,0.0,1.0),3.0), 1.0);

    // vec4 resultColor = vec4(color1.rgb*color*pow(clamp(0.1*5.0,0.0,1.0),3.0), 1.0);
 
    gl_FragColor = resultColor;
}


// precision highp float;
// varying highp vec2 textureCoordinate;

// uniform sampler2D inputImageTexture;
// uniform sampler2D inputImageTextureLast;
// uniform sampler2D bgMask;


// void main() {
//     vec2 uv1 = vec2(textureCoordinate.x,1.0-textureCoordinate.y);
//     vec4 color1 = texture2D(inputImageTexture, textureCoordinate);      //current frame
//     vec4 color2 = texture2D(inputImageTextureLast, textureCoordinate);  //last frame
//     vec4 maskColor = texture2D(bgMask,uv1);

//     vec3 grayW = vec3(0.299,0.587,0.114);

//     float motion = abs(dot(color1.rgb,grayW)-dot(color2.rgb,grayW));
    
//     vec3 color = vec3(pow(motion,1.2)*3.0); 

//     //筛选运动边缘，使其产生烟雾
//     // if(motion > 0.5)
//     //     maskColor.a = 1.0;

// 	vec4 resultColor = vec4(color1.rgb*color*pow(clamp(maskColor.r*5.0,0.0,1.0),3.0), 1.0);
//     gl_FragColor = resultColor;
// }
