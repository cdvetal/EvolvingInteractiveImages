class Individual{
 
  PShader shader;
  String file;
  
  Individual(PShader _shader, String _file){
   shader = _shader;
   file = _file;
  }
  
  PImage getPhenotype(float _w, float _h, float _external, float[] _audioSpectrum, PImage _inputImage) {
    int w = floor(_w);
    int h = floor(_h);
    PGraphics canvas = createGraphics(w, h, P2D);

    canvas.beginDraw();

    render(canvas, _external, _audioSpectrum, _inputImage);

    canvas.endDraw();

    return canvas;
  }

  void render(PGraphics _canvas, float _external, float[] _audioSpectrum, PImage _inputImage) {

    //shader.set("resolution", _w, _h); //doesnt matter
    shader.set("externalVal", _external);
    shader.set("audioSpectrum", _audioSpectrum);
    shader.set("image", _inputImage);
    
    _canvas.shader(shader);
    _canvas.noStroke();
    
    _canvas.rect(0,0,_canvas.width, _canvas.height);
  }
  
}
