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
  const float supp=.8;
  return 1. - pow(smoothstep(-supp, supp, x),2.);
  //return smoothstep(.1, .5, 1/x*x);
  //return 1/(x*x);	
}

// sp: sample point
float eval (vec2 uv, vec2 sp) {
    float weight = samp(sp);
    //weight = 1.;
    vec2 diff = (uv-sp);
    //float d = dot(diff, diff);
    // diff: 0..sqrt(2)
    return weight * basis(diff);

}
float labyrinth(vec2 orig_uv) {
  float scale = 5.;
  vec2 uv = orig_uv*scale;

  /// pos: [-1, 1] x [-1, 1]
  //vec2 pos = vec2(-1) + 2. * fract(uv);
  // cell: even integersrgb
  vec2 cell = floor(uv);
  //float odd = .5;

  float y_bot = cell.y;
  float y_top = cell.y+1.;

  float shift = .5 * mod(cell.y+1.5,2.);
  float x_bot = cell.x + shift;
  float x_top = cell.x - shift;

  float tot = 0.;

  for(int i=-2;i<3;++i)
  {
    tot+=eval(uv,vec2(x_top+float(i),y_top+2.));
    tot+=eval(uv,vec2(x_top+float(i),y_top));
    tot+=eval(uv,vec2(x_bot+float(i),y_bot));
    tot+=eval(uv,vec2(x_bot+float(i),y_bot-2.));
  }
  //tot = 1./length(uv-cell);


//tot=log(tot);
  tot*=.5;
  return tot;
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
  //float line_value = line(wall_value, 0.0);

  //vec3 rgb = colorize(line_value, vec3(1, 1, 1));
  vec3 rgb = colorize(wall_value, vec3(1, 1, 1));

  gl_FragColor = vec4(rgb,1.0);
}


