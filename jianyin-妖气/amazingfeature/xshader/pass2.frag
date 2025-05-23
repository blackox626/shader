precision highp float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D solverTex;
uniform sampler2D bgMask;

void main() {
    vec2 uv = textureCoordinate;
	vec2 uv1 = vec2(uv.x,1.0-uv.y);
    vec4 color1 = texture2D(inputImageTexture, uv);
	vec4 color2 = texture2D(solverTex, uv);
	vec4 maskColor = texture2D(bgMask, uv1);

	vec4 tempColor = color2*color2*0.85*(1.0-pow(clamp(maskColor.r*1.1,0.0,1.0),1.35));

	vec4 resultColor = color1 + tempColor;
	
	resultColor.a = color1.a + dot(tempColor.rgb, vec3(0.33333));
	gl_FragColor = resultColor;
	// gl_FragColor = maskColor;
}
