uniform mat4 modelview;
uniform mat4 projection;
in vec4 position;
in vec4 texCoord;
out vec2 uv;
void main() {
  uv = texCoord.xy;
  gl_Position = projection * modelview * position;
}