#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform float fMidiKnob;

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define time  fGlobalTime
#define u_time  fGlobalTime
#define PI 3.14159

float noise(vec2 uv) {
    return texture2D(texNoise, uv).r;
}

mat2 rot(float a) {
    return mat2(cos(a),-sin(a),sin(a),cos(a));
}

float saw(float x) {
    return 2*abs(mod(x, 1)-.5);
}

float saw2(float x,float speed) {
    float thr=.5;
    float eps=.5*3/speed;
    return smoothstep(thr-eps,thr+eps,2*abs(mod(x, 1)-.5));
}

float[7] intervals = float[7](7.,11.,13.,17,19,23,29);

// todo: instead of sampling noise, return uv coords
vec2 shifty(vec2 uv, float off) {
    
    //return saw2(uv.x);
    float n = 7;
    //float noi = noise(rot(.01*time) * uv);
    float saw = mod(uv.x, 1.);
    float cnt = floor(uv.x);
    float strip = mod(10*cnt,n);
    //return strip/8;
    float interval = intervals[int(strip)%9];
    float shift= saw2(.79+(1*time)/interval,interval);
    //return mod(interval/100,1);
    //mod(time, interval)
    //float shift = saw2((time)/interval);//+.00001*(time+off)); //aw2(4.*(uv.x+.4*time));
    //return shift/5;
    //float bright = .2 + .4*(strip+1)/(n+1);
    //bright = 1;
    return vec2(0, shift);
    
}

float sqlen(vec2 v) {
    return dot(v,v);
}


float gauss(float x) {
    return exp(-pow(x,2));
}
float rbf(float x) {
    float v= smoothstep(0.2,1.0,exp(-pow(x,2)));
    v*=v;
    return v;
    //return 1./pow(x,2);
}

float plop(vec2 uv, float off) {
    vec2 shift = shifty(uv, off);
    vec2 pos = uv + 5*shift;
    
    vec2 c = floor(pos) + vec2(.5);
    
    float v = noise(vec2(1,.1771)*c);
    float wall_thresh=.25;
    //wall_thresh += .02*sin(time);
    float eps=0.001;
    v = smoothstep(wall_thresh-eps, wall_thresh+eps,v);
    
    v *= rbf(1.8*length(pos-c));
    
    //v *= gauss(7*(pos.y-c.y));
    
    return v;
}
float plop2(vec2 uv, float off) {
    float v = 0; // plop(uv, off);
    v+= plop(uv+vec2(0,0), off);
    v+= plop(uv+vec2(0,0.5), off);
    
    v+= plop(uv+vec2(.5,0.3), off);
    v+= plop(uv+vec2(.5,0.8), off);
    //v+= plop(uv+vec2(0.4,0.4), off);
    //v+= plop(uv+vec2(0.8,0.7), off);
    
    //v+= plop(uv+vec2(0.2,0.7), off);
    //v+= plop(uv+vec2(0.2,0.2), off);
    //v+= plop(uv+vec2(0.5,0.7), off);
    //v+= plop(uv+vec2(0.8,0.2), off);
    return v/3;
}

float labyrinth(vec2 uv) {
    //rot(pi/3)*uv;
    //float n = noise(rot(.01*time) * uv);
    //return vec3(plop(rot(PI/3)*uv));

    uv*=10;
    
    uv *= 1+.1*sin(.3*time);
    //uv.x += 4*sin(.4*time);
    
    uv.x += 5*sin(.51*time+.2*sin(2*time));
    
    uv.y += 5*sin(9+.61*time+.2*sin(1*time));
    float v;
    v += plop2(uv,0);
    v += plop2(rot(2*PI/3)*uv,44.723);
    v += plop2(rot(4*PI/3)*uv,3.9);

    return v;
}
    
/*
vec3 color(vec2 uv) {
    float v = labyrinth(uv);
    float thr = .12;
    float eps = .02;
    
    
    v = smoothstep(thr-eps, thr+eps,abs(v-.1));
    //v = smoothstep(thr-eps, thr+eps,v);
    //v = smoothstep(0., eps,abs(v-.1));
    
  
    return vec3(v);

}

*/


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
  //return texture2D(u_texture_0, st).rgb;
  //st.x += 0.2 * u_time;
  //st.y += 0.1 * sin(u_time);

  float ang = 0.7*time + cos(1.7*time);
  st = rot(ang) * st;
  st += 0.06*vec2(noise(st*2.9+vec2(11.3, -15.7+u_time)), noise(st*1.7+vec2(8.3, -1.7-u_time*1.1)));
  float scale = 3.+1.*sin(.3*time);
  scale/=5.;
  st*=scale;
  //return  (lab +vec3(1))/2.;
  float wall_value = labyrinth(st);
  //wall_value = smoothstep(.3 ,.4, wall_value);
    wall_value= wall_value*2 -1;
    //return vec3(wall_value);
    wall_value*=1.4;
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
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    
	out_color = vec4(color(uv), 0.);
}
