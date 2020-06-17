#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
// Pattern 1: Data sent from the sketch to the shaders
uniform sampler2D texture;
// Patter 2: Passing data among shaders
varying vec4 vertColor;
varying vec4 vertTexCoord;

const vec4 lumcoeff = vec4(0.299, 0.587, 0.114, 0);

void main() {
  // Pattern 3: Consistency of space transformations
  vec4 col = texture2D(texture, vertTexCoord.st);
  float lum = dot(col, lumcoeff);
  gl_FragColor = vec4(lum, lum, lum, 1.0) * vertColor;  
}
