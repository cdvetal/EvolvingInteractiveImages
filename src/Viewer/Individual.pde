class Individual {

  PShader shader;
  String file;

  Individual(PShader _shader, String _file) {
    shader = _shader;
    file = _file;
  }
  
  PShader getShader(){
   return shader; 
  }

}
