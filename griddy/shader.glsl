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

float sqlen(vec2 v) {
    return dot(v,v);
}

vec3 tex(vec2 uv) {
    float center_dist = sqlen(fract(uv)-vec2(.5));
    float amt =  exp(1.8*-center_dist);
    amt = sin(30*amt);
    vec2 cell = floor(uv);
    vec3 tmp=vec3(cell.x);
    vec3 col = mod(cell.xyx,vec3(3,4,5));
    return amt * col;
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

int grey(int x, int bitpos) {
    int g = x ^ (x>>1);
    return (g >> bitpos) & 1;
}

float shifty(vec2 uv, int sel) {
    int n_strips = 8;
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

vec3 plop(vec2 uv) 
{
    vec2 orig_uv = uv;
    
    float places = 5;
    float sy = shifty(uv, 0);
    uv.y += places * sy;
    float sx = shifty(ccw(orig_uv),1);
    uv.x += places * sx;
    // uv + places*vec2(sx, sy);
    
    return tex(uv);
}

vec2 cam_uv(vec2 uv) {
    uv = rot(.2*time)*uv;
    uv *= 9+2*sin(time);
    uv.x += 8*sin(.4*time);
    uv.y += 8*sin(.3*time+17);
    return uv;
}

vec3 color(vec2 uv) {
    vec3 col;
    
    uv = cam_uv(uv);
    
    return plop(uv);


}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    
    
	out_color = vec4(color(uv), 0.);
}