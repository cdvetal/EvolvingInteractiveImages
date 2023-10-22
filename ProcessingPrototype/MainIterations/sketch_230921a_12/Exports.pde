void exportAnimation(Individual _individualToExport) { //not working
  int millisStarted = millis();
  int previousMillis = millisStarted;
  isExportingAnimation = true;
  println("Started exporting animation. Sit tight.");

  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");

  float sinInc = (float)(Math.PI*2) / nAnimationFrames;

  for (int i = 0; i < nAnimationFrames; i++) {
    float currentAnimationExternal = map(sin(sinInc * i), -1, 1, minExternal, maxExternal);
    String fileName = nf(i, 5);
    String currentOutputPath = outputPath + fileName;
    _individualToExport.getPhenotype(animationExportResolution, currentAnimationExternal).save(currentOutputPath + ".png");
    
    int thisFrameMillis = millis() - previousMillis;
    println(currentAnimationExternal + "  " + (i+1) + " / " + nAnimationFrames + "  " + thisFrameMillis + "ms");
    previousMillis = millis();
  }
  
  saveStrings(outputPath + _individualToExport.getID() + ".glsl", _individualToExport.getShaderTextLines());
  
  int nNodes = _individualToExport.getTotalChildNodes();
  int totalTime = millis() - millisStarted;
  float timePerFrame = totalTime / nAnimationFrames;
  float timePerNodePerFrame = timePerFrame / nNodes;
  
  println();
  println("Finished exporting animation to: " + outputPath);
  println("Resolution: " + animationExportResolution + "*" + animationExportResolution);
  println("Number of nodes: " + nNodes);
  println("Total time: " + totalTime + "ms");
  println("Avg time per frame: " + timePerFrame + "ms");
  println("Avg time per node per frame: " + timePerNodePerFrame + "ms");

  isExportingAnimation = false;
}

void exportImage(Individual _individualToExport){
  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");
  float imageExternal = (minExternal + maxExternal) / 2;
  
  PImage image = _individualToExport.getPhenotype(imageExportResolution, imageExternal);
  image.save(outputPath + "img.png");
  
  println("exported image to:" + outputPath);
}

void exportShader(Individual _individualToExport){
  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");
  saveStrings(outputPath + _individualToExport.getID() + ".glsl", _individualToExport.getShaderTextLines());
  println("exported shader to :" + outputPath);
}
