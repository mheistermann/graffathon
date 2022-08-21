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

vec3 noise3(vec2 uv) {
    return vec3(noise(uv),
                noise(uv+vec2(.976,.337)),
                noise(uv+vec2(.419,.129)));
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


float gauss(float x) {
    return exp(-pow(x,2));
}

vec2 ccw(vec2 v) {
    return vec2(-v.y, v.x);
}


float sphere(vec3 p, float rad) {
    return length(p)-rad;
}


float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h); }

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h); }

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) + k*h*(1.0-h); }
    

float sdf(vec3 p) {
    vec3 center = vec3(0,0,0);
    
    float d = sphere(p-center,.5);
    for (int i = 0; i < 7; ++i) {
       
        //vec3 off = vec3(1,1,0);
        vec3 axis = normalize(noise3(vec2(10*i*.347, 0))
                            -vec3(.2));
        //off=vec3(0);
        float phase=.3*i;
        vec3 sorig = center + 2.*sin(time+phase)*axis;
        float s = sphere(p-sorig, .6+.2*sin(i+.2*time));
        d = opSmoothUnion(d,s, 1+sin(time));
    }
    
    
    return d;
}

vec3 normal(vec3 p) {
    vec2 d=vec2(1e-3,0);
    float dist = sdf(p);
    return normalize(vec3(
        sdf(p+d.xyy) - dist,
        sdf(p+d.yxy) - dist,
        sdf(p+d.yyx) - dist));     
}

vec3 color(vec2 uv)
{
    
    vec3 color;
    
    vec3 target = vec3(0,0,0);
    
    float camdist=10 + 3*sin(time*.3);
    vec3 cam =  vec3(camdist*sin(time), 3,camdist*cos(time));
    vec3 forward = normalize(target-cam);
    vec3 up = vec3(0,1,0);
    vec3 right = normalize(cross(forward, up));
    
    
    float focal = 1;
    vec3 dir = forward * focal + right*uv.x + up*uv.y;
    //vec3 dir = normalize(vec3(uv,1));
    dir=normalize(dir);
    
    vec3 lpos = vec3(10*rot(time)*vec2(1,0),0);
    lpos = vec3(5,5,0);
    
    vec3 pos = cam;
    int i = 0;
    bool hit = false;
    for (; i < 100; ++i) {
        float d = sdf(pos);
        if (d < 1e-2) {
            hit = true;
            break; 
        }
        if (d > 50) {
            break;
        }
        pos += d * dir;
    }
    vec3 n = normal(pos);
    
    if (hit) {
        vec3 ldir = normalize(lpos-pos);
        float diff = dot(n, ldir);
        
        float spec = 0;
        float br = 0.02;
        
        if (diff > 0) br += diff;
        if (diff > 0) br += spec;
        
        color += vec3(br);
    } else {
        float halo = float(i)/50;
        //halo = exp(-1/(float(i+1))) / 2;
        color += vec3(0,0,1) * halo;
    }
    
    return color;

}

void main(void)
{
	vec2 uv = out_texcoord;
	uv -= 0.5;
	uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

    
	out_color = vec4(color(uv), 0.);
}