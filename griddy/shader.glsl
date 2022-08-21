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

int grey(int x, int bitpos) {
    int g = x ^ (x>>1);
    return (g >> bitpos) & 1;
}

float shifty(vec2 uv, int sel) {
    
    //return saw2(uv.x);
    int n_strips = 8;
    //float noi = noise(rot(.01*time) * uv);
    //float saw = mod(uv.x, 1.);
    int cnt = int(uv.x+100);
    //float strip = mod(10*cnt,n);
    int strip = int(mod(cnt,n_strips));
    
    int tstep = int(time); 
    int bitpos = 2*int(strip)+sel;
    int last = grey(tstep, bitpos);
    int cur = grey(tstep+1, bitpos);
    

    
    float t01 = fract(time);
    float t = smoothstep(0,1,t01);
    float shift = mix(last,cur,t);
    
    return shift;
    
}


float gauss(float x) {
    return exp(-pow(x,2));
}

vec2 ccw(vec2 v) {
    return vec2(-v.y, v.x);
}

float plop(vec2 uv, float off) {
    float sy = shifty(uv, 0);
    float sx = shifty(ccw(uv),1);
    //sy=0;
    //sx=0;
    //shiftx=0;
    //shift=shifty(ccw(shift), off);
    float places = 4;
    vec2 pos = uv + places*vec2(sx, sy);
    
    vec2 c = floor(pos) + vec2(.5);
    
    float v = noise(.03123*c);
    
    v *= gauss(1*length(fract(abs(pos-c))));
    
    //v *= gauss(7*(pos.y-c.y));
    
    return v;
}

vec3 color(vec2 uv) {
    //rot(pi/3)*uv;
    //float n = noise(rot(.01*time) * uv);
    //return vec3(plop(rot(PI/3)*uv));
    vec3 col;
    //uv*=9;
    
    uv = rot(.2*time)*uv;
    uv *= 9+2*sin(time);
    uv.x += 8*sin(.4*time);
    
    uv.y += 8*sin(.4*time);
    
    //uv.x += sin(.51*time+.2*sin(2*time));
    col += vec3(0,1,0)*plop(uv,0);
    //col += vec3(1,0,0)*plop(rot(2*PI/3)*uv,44.723);
    //col += vec3(0,0,1)*plop(rot(4*PI/3)*uv,3.9);
    return col;

}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    
    
	out_color = vec4(color(uv), 0.);
}