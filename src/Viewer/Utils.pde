//gets

PImage getPhenotype(float _w, float _h, PShader _shader, float[] _variables, float[] _audioSpectrum, PImage _inputImage) {
  int w = floor(_w);
  int h = floor(_h);
  PGraphics canvas = createGraphics(w, h, P2D);

  _shader.set("resolution", _w, _h);
  _shader.set("nVariables", variablesManager.nVariables);
  _shader.set("variables", _variables);
  _shader.set("audioSpectrum", _audioSpectrum);
  _shader.set("image", _inputImage);

  canvas.beginDraw();

  canvas.shader(_shader);

  canvas.noStroke();

  canvas.rect(0, 0, canvas.width, canvas.height);

  canvas.endDraw();

  return canvas;
}

PImage getImageInput(){
  if (cam != null && cam.available() == true) {
    cam.read();
    return cam;
  }

  return exampleImage;
}

float[] getAudioSpectrum() {
  float[] spectrum = new float[nBands];
  fft.analyze(spectrum);
  return spectrum;
}

//changes

void changeSong() {
  if(!songPlaying) return;
  
  soundFiles[soundIndex].stop();
  soundIndex ++;

  if (soundIndex >= soundFiles.length) soundIndex = 0;

  soundFiles[soundIndex].loop();
  fft.input(soundFiles[soundIndex]);
}

void muteSong() {
  if(songPlaying) soundFiles[soundIndex].stop();
  else soundFiles[soundIndex].loop();
  
  songPlaying =! songPlaying;
}

//loads

SoundFile[] loadSongs() {
  String directory = sketchPath("music/");

  File f = dataFile(directory);
  String[] names = f.list();

  SoundFile[] toReturn = new SoundFile[names.length];

  for (int i = 0; i < toReturn.length; i++)
  {
    toReturn[i] = new SoundFile(this, directory + names[i]);
  }

  return toReturn;
}


Individual[] loadIndividuals() {
  String directory = "/shaders";

  File f = dataFile(directory);
  String[] names = f.list();
  //Collections.shuffle(Arrays.asList(names));

  Individual[] individualsToReturn = new Individual[names.length];

  for (int i = 0; i < names.length; i++) {
    PShader shader = loadShader(directory + "/" + names[i]);
    individualsToReturn[i] = new Individual(shader, names[i]);
  }

  return individualsToReturn;
}
