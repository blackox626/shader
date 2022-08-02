#iChannel0 "file://image.png"

#define D_MAX 5
const float D2 = float(D_MAX * 2 + 1);

//finds distance to closest sign change on the horizontal axis
float source(vec2 uv)
{
    // float c = dot(texture(iChannel0, uv).xyz, vec3(0.3, 0.59, 0.11));
    float threshold = 0.5;
    return texture(iChannel0, uv).a - threshold; 
}

void main() {

    vec2 ir = 1./ iResolution.xy;
    vec2 uv = gl_FragCoord.xy * ir;
    
	float s = sign(source(uv));
	float d = 0.;	
	for(int i= 0; i < D_MAX; i++) {
        d ++;
		vec2 offset =  vec2((d) * ir.x, 0.);

		if(s * source(uv + offset) < 0.)break;
		if(s * source(uv - offset) < 0.)break; 
	}

	float sd = -s * d / D2 + 0.5;
    gl_FragColor = vec4(vec3(sd),1.0);
}