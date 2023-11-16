void exportImage(Individual _individualToExport){
  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");
  float imageExternal = (minExternal + maxExternal) / 2;
  
  PImage image = _individualToExport.getPhenotype(imageExportResolution, imageExportResolution, imageExternal, getAudioSpectrum());
  image.save(outputPath + "img.png");
  
  println("exported image to:" + outputPath);
}

void exportShader(Individual _individualToExport){
  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");
  saveStrings(outputPath + _individualToExport.getID() + ".glsl", _individualToExport.getShaderTextLines());
  println("exported shader to :" + outputPath);
}
