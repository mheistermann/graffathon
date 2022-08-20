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
  //float thr = .3+.08*sin(.3*time);
  float thr = .3;
  float eps=.002;
  //return -1. + 2. * step(thr, noise(p));
  return -1. + 2. * smoothstep(thr-eps, thr+eps, noise(p+vec2(0,-.1*sin(time))));
}

// v in [-1,1] x [-1,1]
float basis(vec2 v) {

  float x = length(v);
  //vec2 z = pow(abs(v), vec2(2));
  //x = z.x+z.y;
  const float supp=.7;
  //return 1. - pow(smoothstep(-supp, supp, x),2.);
  return 1. - pow(smoothstep(-supp, supp, x),1.2);
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
  float scale = 5.;

  vec2 uv = orig_uv * scale;
  vec2 cell = floor(uv);

  vec3 tot = vec3(0.);

  vec3 w1=vec3(1,0,0);
  vec3 w2=vec3(0,1,0);
  vec3 w3=vec3(0,0,1);
  
  const int minx = -1;
  const int maxx = 2;
  const int miny = -1;
  const int maxy = 2;
  for (int x=minx;x<=maxx;++x) {
    for(int y=miny;y<=maxy;++y){
      float fx=float(x);
      float fy=float(y);
      tot-= .4 * eval(uv,shrow(cell+vec2(fx,fy)),w1); // wall corners
      tot+=sampeval(uv,shrow(cell+vec2(-.5+fx,fy)),w1);// horiz

      tot+=sampeval(uv,cell+vec2( -.25+fx,.5+fy),w1); // vert
      tot+=sampeval(uv,cell+vec2( +.25+fx,.5+fy),w1); // center
    }
  }

  //tot += .2*sin(u_time);
  //return vec3(-1,0,0);
  return tot;
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

vec3 color(vec2 st)
{
  //st.x += 0.2 * u_time;
  //st.y += 0.1 * sin(u_time);

  st += 0.06*vec2(noise(st*2.9+vec2(11.3, -15.7+u_time)), noise(st*1.7+vec2(8.3, -1.7-u_time*1.1)));
  float scale = 6.+3.*sin(.3*time);
  scale/=5.;
  st*=scale;
  vec3 lab = labyrinth(st);
  //return  (lab +vec3(1))/2.;
  float wall_value = lab.r;
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

return rgb;
}




void main(void)
{
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  st.x *= u_resolution.x/u_resolution.y;
  gl_FragColor = vec4(color(st),1.0);
}