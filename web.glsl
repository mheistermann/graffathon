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
  const float supp=.3;
  return 1. - pow(smoothstep(-supp, supp, x),2.);
  //return smoothstep(.1, .5, 1/x*x);
  //return 1/(x*x);	
}

// sp: sample point
vec3 eval (vec2 uv, vec2 sp, vec3 weight) {
    //float weight = samp(sp);
    //weight = 1.;
    vec2 diff = (uv-sp);
    //float d = dot(diff, diff);
    // diff: 0..sqrt(2)
    return weight * basis(diff);
}




vec3 labyrinth(vec2 orig_uv) {
  float scale = 5.;

  vec2 uv = orig_uv * scale;
  vec2 cell = floor(uv);

  vec3 tot = vec3(0.);

  cell.x += .5*mod(cell.y, 2.);
  const int dy=2;
  const int dx=2;
  vec3 weight=vec3(0,1,0);
  //weight=vec3(cell,0.);

//  tot+=eval(uv,cell+vec2(-1.5,0),weight);

  
  vec3 w2=vec3(1,0,0);
  vec3 w3=vec3(0,0,1);
  tot+=eval(uv,cell+vec2( -.5,0),weight); // BL
  tot+=eval(uv,cell+vec2(  .5,0),weight); // BR
  tot+=eval(uv,cell+vec2( 0, 1),weight); // TL
  tot+=eval(uv,cell+vec2( 1, 1),weight); // TR
  //tot+=eval(uv,cell+vec2( 1.5,0),weight);

  tot+=eval(uv,cell+vec2( -.25,.5),w3); // L / R

  tot+=eval(uv,cell+vec2( 0,0),w2); // B
  tot+=eval(uv,cell+vec2(  1,0),w2); // B + (1,0)
  tot+=eval(uv,cell+vec2( 0.5, 1),w2); // T
  tot+=eval(uv,cell+vec2( -0.5, 1),w2); // T - (1,0)

  //tot+=eval(uv,cell+vec2(-1, 1),weight);

  /*
  tot+=eval(uv,cell+vec2(-1,-1),weight);
  tot+=eval(uv,cell+vec2( 0,-1),weight);
  tot+=eval(uv,cell+vec2( 1,-1),weight);
  */

/*
  for(int oy=-dy; oy<=dy;++oy)
  {
    for(int ox=-dx; ox<=dx;++ox)
    {
      float y = cell.y+float(oy);
      float x = cell.x+float(ox);
      float a = mod(x, 2.);
      float b = mod(y, 2.);
      float c = mod(x+y+y, 2.);

      vec3 weight = vec3(1,1,a);
      //x += .5*mod(y,2.);
      tot+=eval(uv,vec2(x,y), weight);
    }
  }
  */
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


  //st.x += 0.05 * u_time;

  vec3 rgb =  labyrinth(st);
  //float wall_value = labyrinth(st);
  //float line_value = line(wall_value, 0.0);

  //vec3 rgb = colorize(line_value, vec3(1, 1, 1));
  //vec3 rgb = colorize(wall_value, vec3(1, 1, 1));

  gl_FragColor = vec4(rgb,1.0);
}


