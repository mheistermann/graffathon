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

float line(float value)
{
  float thr1 = 0.07;
  float thr2 = 0.00;
  return smoothstep(-thr1, -thr2, value) - smoothstep(thr2, thr1, value);
}

vec3 colorize(float value, vec3 col)
{
  return 1.0-(1.0-col)*value;
}

void main(void)
{
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  st.x *= u_resolution.x/u_resolution.y;


  st.x += 0.05 * u_time;

  st += 0.1*vec2(noise(st*2.9+vec2(11.3, -15.7+u_time)), noise(st*1.7+vec2(8.3, -1.7-u_time*1.1)));

  float wall_value = labyrinth(st);
  float amplitude_r = 0.15+0.05*noise(vec2(-st.y*1.25+8.7, st.x*1.75-0.7));
  float amplitude_g = 0.2+0.05*noise(vec2(st.y*8.25+1.7*st.y, st.x*0.75-1.7*st.y));
  float amplitude_b = 0.25+0.05*noise(vec2(-st.x*2.76+1.75, st.x*1.75-0.7));
  float line_value_r = line(wall_value + amplitude_r*noise(st*50.0+vec2(11.3, 27.5+u_time*0.3)));
  float line_value_g = line(wall_value + amplitude_g*noise(st*70.0+vec2(-23.5+u_time*1.7, 1.3-u_time*0.3)));
  float line_value_b = line(wall_value + amplitude_b*noise(st*100.0+vec2(11.3+u_time*2.3, 27.5)));

  vec3 rgb = min(
    colorize(line_value_r, vec3(0.8588, 0.4902, 0.5569)),
    min(
      colorize(line_value_g, vec3(0.2941, 0.4314, 0.0588)),
      colorize(line_value_b, vec3(0.1451, 0.3922, 0.4196))
    )
  );

  gl_FragColor = vec4(rgb,1.0);
}


