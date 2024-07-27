void drawPhenotype(float _x, float _y, float _w, float _h, PShader _shader, float[] _audioSpectrum, PImage _inputImage) {
  int w = floor(_w);
  int h = floor(_h);
  
  _shader.set("audioSpectrum", _audioSpectrum);
  _shader.set("image", _inputImage);

  shader(_shader);
  noStroke();
  rect(_x, _y, w, h);
  resetShader();
}

String[] getShaderTextLines(Node _node) {
  String[] shaderLines = fragShaderTemplateLines.clone();

  String[] expressions = _node.getExpressions();

  shaderLines[shaderChangeLineStart] =     "    float r = " + expressions[0] + ";";
  shaderLines[shaderChangeLineStart + 1] = "    float g = " + expressions[1] + ";";
  shaderLines[shaderChangeLineStart + 2] = "    float b = " + expressions[2] + ";";

  return shaderLines;
}

int findLineToChangeInShader(String[] _shaderTemplateStrings) {
  String lineStartString = "float r = ";

  for (int i = 0; i < _shaderTemplateStrings.length; i ++) {
    if (_shaderTemplateStrings[i].indexOf(lineStartString) >= 0) {
      return i;
    }
  }
  return 0;
}

float[] getAudioSpectrum() {
  float[] spectrum = new float[nBands];
  fft.analyze(spectrum);
  return spectrum;
}
