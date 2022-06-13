uniform float time;
uniform float progress;
uniform sampler2D texture1f;
uniform sampler2D texture1e;
uniform sampler2D texture3f;
uniform sampler2D texture3e;

uniform int videoIndex;

varying vec2 vUv;
varying vec3 vPosition;

float PI = 3.141592653589793238;

void main(){

  vec4 v1f = texture2D(texture1f,vUv);
  vec4 v3f = texture2D(texture3f,vUv);
  vec4 v1e = texture2D(texture1e,vUv);
  vec4 v3e = texture2D(texture3e,vUv);
  vec4 finalTextrue;
  // gl_FragColor = vec4(vUv,0.,1.);
  if(bool(videoIndex % 2)){
    // finalTextrue =vec4(0.,0.,1.,1.);
    finalTextrue = mix(v1f,v3e,progress);
  }else{
    // first time
    finalTextrue = mix(v1e,v3f,progress);
    // finalTextrue =vec4(1.,0.,0.,1.);
  }
  gl_FragColor = finalTextrue;
  if(finalTextrue.r <0.1 && finalTextrue.b<0.1 && finalTextrue.g<0.1) discard;
  
  // gl_FragColor = vec4(1.,1.,1.,0.5);
  // gl_FragColor = vec4(1.,0.,0.,0.5);
}