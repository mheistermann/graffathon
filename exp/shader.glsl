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

float saw2(float x) {
    float thr=.9;
    float eps=.1;
    return smoothstep(thr-eps,thr+eps,2*abs(mod(x, 1)-.5));
}

float[9] intervals = float[9](3.,5.,7.,11.,13.,17,19,23,29);

float plop(vec2 uv, float off) {
    
    //return saw2(uv.x);
    float n = 9.;
    float noi = noise(rot(.01*time) * uv);
    float saw = mod(uv.x, 1.);
    float cnt = floor(uv.x);
    float strip = mod(cnt,n);
    float interval = intervals[int(strip+.5)];
    //mod(time, interval)
    float shift = saw2(off+strip/n+.1*time); //aw2(4.*(uv.x+.4*time));
    float bright = (strip+1)/(n+1);
    bright = 1;
    return bright * noise(uv+vec2(0, shift/3));
    
}

vec3 color(vec2 uv) {
    //rot(pi/3)*uv;
    //float n = noise(rot(.01*time) * uv);
    //return vec3(plop(rot(PI/3)*uv));
    vec3 col;
    
    uv *= 6+sin(time);
    uv.x += sin(.4*time);
    
    uv.x += sin(.51*time+.2*sin(2*time));
    col += plop(uv,0);
    col += plop(rot(2*PI/3)*uv,5);
    col += plop(rot(4*PI/3)*uv,19);
    return col;

}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    
    
	out_color = vec4(color(uv), 0.);
}