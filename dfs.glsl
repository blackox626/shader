// https://www.shadertoy.com/view/ttSXDK

#iChannel0 "file:///shadertoy4.png"

#define D_MAX 255
const float D2 = float(D_MAX * 2 + 1);

//finds distance to closest sign change by iterating over the vertical axis and sampling the horizontal axis. 
//the minimum distance (length(i, dx)) is output.
float sd(vec2 uv)
{
    float x = texture(iChannel0, uv).x;
    x = x - 0.5;
	return x * D2;
}

void main()
{
    vec2 ir = 1./ iResolution.xy;
    vec2 uv = gl_FragCoord.xy * ir;

    //if(uv.x < 0.5){
    //    fragColor = texture(iChannel0, uv);
    //}else{
    
        float dx = sd(uv);
        float dMin = abs(dx);
        float dy = 0.;

        for(int i= 0; i < D_MAX; i++){
            dy += 1.;
            vec2 offset =  vec2(0., dy * ir.y);

            float dx1 = sd(uv + offset);

            //sign switch
            if(dx1 * dx < 0.){
                dMin = dy;
                break;
            }

            dMin = min(dMin, length (vec2(dx1, dy)));

            float dx2 = sd(uv - offset);

            //sign switch
            if(dx2 * dx < 0.){
                dMin = dy;
                break;
            }

            dMin = min(dMin, length (vec2(dx2, dy)));

            if(dy > dMin)break;
        }

        dMin *= sign(dx);
		float d = dMin/D2;
    	// float d = dMin * 0.004;
        d = 1.0 - d;
        d = smoothstep(0.8 ,1.0, d);

    
        // //iq coloring
        // vec3 col = vec3(1.0) - sign(d)*vec3(0.1,0.4,0.7);
        // col *= 1.0 - exp(-4.0*abs(d));
        // col *= 0.8 + 0.2*cos(140.0*d);
        // col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.015,abs(d)) );

        gl_FragColor = vec4(vec3(d),1);
   // }
}

	