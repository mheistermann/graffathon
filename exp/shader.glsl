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
    float v= smoothstep(0.3,1.2,exp(-pow(x,2)));
    v*=v;
    return v;
    //return 1./pow(x,2);
}

float plop(vec2 uv, float off) {
    vec2 shift = shifty(uv, off);
    vec2 pos = uv + 5*shift;
    
    vec2 c = floor(pos) + vec2(.5);
    
    float v = noise(.3871*c);
    float wall_thresh=.23+.02*sin(time);
    float eps=0.001;
    v = smoothstep(wall_thresh-eps, wall_thresh+eps,v);
    
    v *= rbf(1.6*length(pos-c));
    
    //v *= gauss(7*(pos.y-c.y));
    
    return v;
}
float plop2(vec2 uv, float off) {
    float v = plop(uv, off);
    v+= plop(uv+vec2(0,0.5), off);
    v+= plop(uv+vec2(0.2,0.1), off);
    v+= plop(uv+vec2(0.5,0.2), off);
    v+= plop(uv+vec2(0.8,0.2), off);
    return v/5;
}

float lab(vec2 uv) {
    //rot(pi/3)*uv;
    //float n = noise(rot(.01*time) * uv);
    //return vec3(plop(rot(PI/3)*uv));
    float col;
    uv*=9;
    
    uv *= 1+.1*sin(.3*time);
    //uv.x += 4*sin(.4*time);
    
    uv.x += 5*sin(.51*time+.2*sin(2*time));
    
    uv.y += 5*sin(9+.61*time+.2*sin(1*time));
    
    col += plop2(uv,0);
    //col += vec3(0,1,0)*plop(uv+vec2(0,.5),0);
    col += plop2(rot(2*PI/3)*uv,44.723);
    col += plop2(rot(4*PI/3)*uv,3.9);
    float thr = .01;
    float eps = .1;
    col = smoothstep(0., .7, col);
    return col;

}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    
    float l = lab(uv);
    
    vec3 rgb=vec3(l);
	out_color = vec4(rgb, 0.);
}