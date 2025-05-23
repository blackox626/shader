#iChannel0 "file://yaoqi/pass0.glsl"
// #iChannel0 "file://yaoqi/image1.png"
#iChannel1 "file://yaoqi/noise.png"
#iChannel2 "self"

#define speed 0.005
#define range 3.5

#define imageWidth 1126
#define imageHeight 2000

void main() {
    float t = mod(iTime,1.0);
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 uv1 = uv;
    // vec2 uv1 = vec2(uv.x,1.0-uv.y);
    vec2 scaleuv = uv;

    vec4 scColor = texture2D(iChannel0,scaleuv);
		
		float ratio = float(imageWidth)/float(imageHeight);
		// float rd = fit(rand(uv),-1.0,1.0,0.05,0.1);
		vec2 noise1 = 	texture2D(iChannel1,uv1*vec2(ratio,1.2) - t*0.55).xy;
		vec2 noise = 	texture2D(iChannel1,uv1*vec2(ratio,1.2) + noise1*0.065 + t*0.15).xy;
		
		noise = noise * 2.0 - 1.0;
		vec4 newVal = texture2D(iChannel2 ,uv+noise*speed);	//speed 0.005 0.015 0.045

		vec4 resultColor = vec4(0.95, 0.85, 1.0, 1.0) * newVal * clamp(noise1.x+0.5,0.0,0.955)*0.975;	//0.975 削弱色彩强度
		vec2 noise2 = texture2D(iChannel1,uv1*vec2(ratio,1.2)*5.0 - t*1.55).xy;
		resultColor = resultColor+scColor * length(noise*noise2) * range; //range is 3.5	,0 to 7
		// resultColor.a = 1.0;
		gl_FragColor = resultColor;
}


// precision highp float;
// varying highp vec2 textureCoordinate;

// uniform sampler2D noiseTex;
// uniform sampler2D sourceTex1;	//grabframe
// uniform sampler2D solverTex;	//grabframe
// uniform float uTime;
// uniform int imageWidth;
// uniform int imageHeight;

// uniform float speed;
// uniform float range;


// void main() {
//         float t = mod(uTime,1.0);
// 		vec2 uv = textureCoordinate;
// 		vec2 uv1 = vec2(uv.x,1.0-uv.y);
// 		vec2 scaleuv = textureCoordinate;
// 		// scaleuv = (scaleuv - 0.5)*1.0 + 0.5;

// 		vec4 scColor = texture2D(sourceTex1,scaleuv);
		
// 		float ratio = float(imageWidth)/float(imageHeight);
// 		// float rd = fit(rand(uv),-1.0,1.0,0.05,0.1);
// 		vec2 noise1 = 	texture2D(noiseTex,uv1*vec2(ratio,1.2) - t*0.55).xy;
// 		vec2 noise = 	texture2D(noiseTex,uv1*vec2(ratio,1.2) + noise1*0.065 + t*0.15).xy;
		
// 		noise = noise * 2.0 - 1.0;
// 		vec4 newVal = texture2D(solverTex ,uv+noise*speed);	//speed 0.005 0.015 0.045

// 		vec4 resultColor = vec4(0.95, 0.85, 1.0, 1.0) * newVal * clamp(noise1.x+0.5,0.0,0.955)*0.975;	//0.975 削弱色彩强度
// 		vec2 noise2 = texture2D(noiseTex,uv1*vec2(ratio,1.2)*5.0 - t*1.55).xy;
// 		resultColor = resultColor+scColor * length(noise*noise2) * range; //range is 3.5	,0 to 7
// 		// resultColor.a = 1.0;
// 		gl_FragColor = resultColor;
// }
