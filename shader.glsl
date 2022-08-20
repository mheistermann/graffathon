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


vec3 col(vec2 uv) {
  vec2 scaled_uv = uv*5;
  vec2 pos = fract(scaled_uv);
  vec2 cell = floor(scaled_uv);


  const vec2 spoints[6] = vec2[6](
      vec2(0,0),
      vec2(0.5,0),
      vec2(1,0),
      vec2(1,.5),
      vec2(1,1),
      vec2(.5,.5)
      );
	

  const float x[6] = float[6]( 1,-1, 1, 1, 1, -1);

  float total = 0;
  //float dist[6];
  for (int i = 0; i < 6; ++i) {
    vec2 diff = (pos-spoints[i]);
    //float d = dot(diff, diff);
	  
    float d = 1/length(diff);
    total += x[i] * d;
  }

  //vec3 x = vec3(1,1,0);


  total=smoothstep(.5,.6,total);
  return vec3(total);
  //return vec3(fract(pos*5), 0);
}

void main(void)
{
  vec2 uv = out_texcoord;
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);


  vec3 rgb = col(uv);
  out_color = vec4(rgb, 1);
}
