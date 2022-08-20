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
  float thr = .4;
  float eps = -.1;
  return -1. + 2. * smoothstep(thr-eps, thr+eps, noise(p*100234.));
}

// v in [-1,1] x [-1,1]
float basis(vec2 v) {

  float x = length(v);
  //vec2 z = pow(abs(v), vec2(2));
  //x = z.x+z.y;
  const float supp=.7;
  return 1. - pow(smoothstep(-supp, supp, x),2.);
  //return smoothstep(.1, .5, 1/x*x);
  //return 1/(x*x);	
}

vec3 eval (vec2 uv, vec2 sp, vec3 weight) {
    //float weight = samp(sp);
    //weight = 1.;
    vec2 diff = (uv-sp);
    //float d = dot(diff, diff);
    // diff: 0..sqrt(2)
    return weight * basis(diff);
}
vec3 sampeval (vec2 uv, vec2 sp, vec3 weight) {
  return samp(sp) * eval(uv, sp, weight);
}
// sp: sample point

vec2 shrow(vec2 sp){
    sp.x+=.5*mod(sp.y,2.);
    return sp;
}



vec3 labyrinth(vec2 orig_uv) {
  float scale = 4.;

  vec2 uv = orig_uv * scale;
  vec2 cell = floor(uv);

  vec3 tot = vec3(0.);

  vec3 w1=vec3(1,0,0);
  vec3 w2=vec3(0,1,0);
  vec3 w3=vec3(0,0,1);
  
  const int dd = 2;
  const int dx=dd;
  const int dy=dd;
  for (int x=-dx;x<=dx;++x) {
    for(int y=-dy;y<=dy;++y){
      float fx=float(x);
      float fy=float(y);
      tot-=eval(uv,shrow(cell+vec2(fx,fy)),w1); // wall corners
      tot+=sampeval(uv,shrow(cell+vec2(-.5+fx,fy)),w1);// horiz

      tot+=sampeval(uv,cell+vec2( -.25+fx,.5+fy),w1); // vert
      tot+=sampeval(uv,cell+vec2( +.25+fx,.5+fy),w1); // center
    }
  }

  tot += .2*sin(u_time);
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


  //st.x += 0.05 * u_time;

  //vec3 rgb =  labyrinth(st);
  float wall_value = labyrinth(st).r;
  float line_value = line(wall_value, 0.0);

  vec3 rgb = colorize(line_value, vec3(1, 1, 1));
  //vec3 rgb = colorize(wall_value, vec3(1, 1, 1));

  gl_FragColor = vec4(rgb,1.0);
}


