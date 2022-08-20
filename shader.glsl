#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

//uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
//uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
//uniform sampler1D texFFTIntegrated; // this is continually increasing
//uniform sampler2D texPreviousFrame; // screenshot of the previous frame
//uniform float fMidiKnob;

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

float samp(vec2 p) {
	return -1 + 2 * smoothstep(.49, .51, noise(p));
}

float rbf(float x) {
	//return smoothstep(.1, .5, 1/x*x);
	return 1/(x*x);	
}


vec3 col(vec2 uv) {
  vec2 scaled_uv = uv*5;
  vec2 pos = vec2(-1) + 2 * fract(scaled_uv);
  vec2 cell = 2 * floor(scaled_uv);

	
	
  const vec2 spoints[9] = vec2[9](
	vec2( 0, 1),  // r
	vec2( 0,-1),  // l 
	vec2( 1, 0),  // t
	vec2(-1, 0),  // b
	
	vec2( 1, 1),  // tr
	vec2(-1,-1),  // bl
	vec2( 1,-1),  // tl
	vec2(-1, 1),  // br
	
	vec2( 0, 0)   // center
      );

	
  float x[9] = float[9](
	samp(cell+spoints[0]),
	samp(cell+spoints[1]),
	samp(cell+spoints[2]),
	samp(cell+spoints[3]),
	-1, -1, -1, -1, // corners
	1 // TODO
	);
	


  float total = 0;
  //float dist[6];
  for (int i = 0; i < 9; ++i) {
    vec2 diff = (pos-spoints[i]);
    //float d = dot(diff, diff);
	  
    float d = rbf(length(diff));
    total += x[i] * d;
  }

  //vec3 x = vec3(1,1,0);


  //total=smoothstep(.5,.6,total);
  return vec3(total);
  //return vec3(fract(pos*5), 0);
}

void main(void)
{
  vec2 uv = out_texcoord;
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

	uv.x += 0.05 * fGlobalTime;

  vec3 rgb = col(uv);
  out_color = vec4(rgb, 1);
}
