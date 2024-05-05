class IndividualScreen {

  Individual[] individuals;

  int individualIndex = 0;

  float transitionTime = 1000;
  float transitionTimeLeft = 0;
  boolean transitionDirection;
  int lastFrameMillis;

  IndividualScreen() {
    individuals = loadIndividuals();
  }

  void show() {
    float[] variables = variablesManager.getShaderReadyVariables();
    float[] audioSpectrum = getAudioSpectrum();
    PImage imageInput = getImageInput();

    background(255, 0, 0);

    if (transitionTimeLeft <= 0) {
      noTint();
      PImage shaderImage = getPhenotype(width, height, individuals[individualIndex].getShader(), variables, audioSpectrum, imageInput);
      image(shaderImage, 0, 0);
    } else {
      int timePassed = millis() - lastFrameMillis;
      transitionTimeLeft -= timePassed;
      lastFrameMillis = millis();

      float transitionRatio = transitionTimeLeft / transitionTime;
      float transparencyRatio = transitionRatio * 255;

      tint(255, 255 - transparencyRatio);
      PImage shaderImageNext = getPhenotype(width, height, individuals[getNextIndex(transitionDirection)].getShader(), variables, audioSpectrum, imageInput);
      image(shaderImageNext, 0, 0);

      tint(255, transparencyRatio);
      PImage shaderImageCurrent = getPhenotype(width, height, individuals[individualIndex].getShader(), variables, audioSpectrum, imageInput);
      image(shaderImageCurrent, 0, 0);

      if (transitionTimeLeft <= 0) {
        individualIndex = getNextIndex(transitionDirection);
      }
    }
  }

  void startTransition(boolean _next) {
    transitionDirection = _next;
    transitionTimeLeft = transitionTime;
  }

  int getNextIndex(boolean _next) {
    int nextIndex = _next ? individualIndex +1 : individualIndex -1;

    if (nextIndex < 0) nextIndex = individuals.length - 1;
    else if (nextIndex >= individuals.length) nextIndex = 0;
    
    return nextIndex;
  }
  
  String getCurrentIndividualName(){
    return individuals[individualIndex].file;
  }
}
