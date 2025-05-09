// precision highp float;
// varying highp vec2 textureCoordinate;
// uniform sampler2D inputImageTexture;

// uniform lowp float intensity;

#iChannel0 "file:///Users/blackox626/shader/image.jpeg"

float v(in vec2 uv, float d, float o) {
    return 1.0-smoothstep(0.0, d, distance(uv.x,(uv.y)*0.3));
}

vec4 b(vec2 uv, float o) {
 float d = 0.05+abs((o*0.2))*0.25 * distance(uv.y+0.5, 0.0);
 return vec4(v(uv+vec2(d*0.25, 0.0), d, o), 0.0, 0.0, 0.1) +
        vec4(0.0, v(uv-vec2(0.015, 0.005), d, o), 0.0, 0.1) + 
        vec4(0.0, 0.0, v(uv-vec2(d*0.5, 0.015), d, o), 0.1);   
}

void main() {

    highp vec2 uv = gl_FragCoord.xy/iResolution.xy;

    float iTime = 0.8;
	float changeValue = 0.5 * 1.;

	vec4 rgba = texture(iChannel0,uv);
	rgba += b(vec2(uv.x - 0.01 - changeValue,uv.y), iTime)*0.2;
	rgba += b(vec2(uv.x - 0.1 - changeValue,uv.y), iTime)*0.2;
	rgba += b(vec2(uv.x - 0.5 - changeValue,uv.y), iTime)*0.2;
	gl_FragColor = rgba;

}
