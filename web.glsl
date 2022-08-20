// http://editor.thebookofshaders.com/

// Author:
// Title:

#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;




#define time u_time

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
  return -1. + 2. * smoothstep(.49, .51, noise(p));
}

// v in [-1,1] x [-1,1]
float basis(vec2 v) {

  float x = length(v);
  //vec2 z = pow(abs(v), vec2(2));
  //x = z.x+z.y;
  const float supp=1.;
  return 1. - pow(smoothstep(-supp, supp, x),2.);
  //return smoothstep(.1, .5, 1/x*x);
  //return 1/(x*x);	
}

float labyrinth(vec2 uv) {
  vec2 scaled_uv = uv*5.;
  vec2 pos = vec2(-1) + 2. * fract(scaled_uv);
  vec2 cell = 2. * floor(scaled_uv);



  vec2 spoints[9];
  spoints[0] = vec2( 0, -1);  // l    
  spoints[1] = vec2( 0,  1);  // r    
  spoints[2] = vec2( 1,  0);  // t
  spoints[3] = vec2(-1,  0);  // b
  spoints[4] = vec2( 1, 1);  // tr
  spoints[5] = vec2(-1,-1);  // bl
  spoints[6] = vec2( 1,-1);  // tl
  spoints[7] = vec2(-1, 1);  // br
  spoints[8] = vec2( 0, 0);  // center    


  float x[9];
  for (int i = 0; i < 4; ++i) {
    x[i] = samp(cell+spoints[i]);
  }
  x[4] = -1.;
  x[5] = -1.;
  x[6] = -1.;
  x[7] = -1.;
  x[8] = 1.;



  float total = 0.;
  //float dist[6];
  for (int i = 0; i < 9; ++i) {
    vec2 diff = (pos-spoints[i]);
    //float d = dot(diff, diff);

    // diff: 0..sqrt(2)
    total += x[i] * basis(diff);
  }

  return total;
}

float line(float value, float shift) {
  if (value <-0.1 || value > 0.1) return 0.0;
  return 1.0;
}

vec3 colorize(float value, vec3 col)
{
  return col*value;
}

void main(void)
{
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  st.x *= u_resolution.x/u_resolution.y;


  st.x += 0.05 * u_time;

  float wall_value = labyrinth(st);
  float line_value = line(wall_value, 0.0);

  vec3 rgb = colorize(line_value, vec3(1, 1, 1));

  gl_FragColor = vec4(rgb,1.0);
}


