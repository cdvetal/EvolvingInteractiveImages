

uniform mat4 modelview;
uniform mat4 projection;
attribute vec4 position;
attribute vec4 texCoord;
varying vec2 uv;
void main() {
  uv = texCoord.xy;
  gl_Position = projection * modelview * position;
}