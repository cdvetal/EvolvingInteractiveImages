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


String generateUUID() {
  String characters = "abcdefghijklmnopqrstuvwxyz0123456789";
  int[] nCharsPerSequence = {8, 4, 4, 4, 12};
  String[] sequences = new String[5];


  for (int i = 0; i < sequences.length; i++) {
    sequences[i] = "";
    for (int j = 0; j < nCharsPerSequence[i]; j++) {
      int index = floor(random(characters.length()));
      sequences[i] += characters.charAt(index);
    }
  }

  return String.join("-", sequences);
}

void changeSong() {
  soundFiles[soundIndex].stop();
  soundIndex ++;

  if (soundIndex >= soundFiles.length) soundIndex = 0;

  soundFiles[soundIndex].loop();
  muteSong();
  fft.input(soundFiles[soundIndex]);
}

void muteSong() {
  soundFiles[soundIndex].amp(muted ? 0 : 1);
}

SoundFile[] loadSongs() {
  String directory = sketchPath("data/music/");

  File f = dataFile(directory);
  String[] names = f.list();

  SoundFile[] toReturn = new SoundFile[names.length];

  for (int i = 0; i < toReturn.length; i++)
  {
    toReturn[i] = new SoundFile(this, directory + names[i]);
  }

  return toReturn;
}

HashMap<String, PShape> loadIcons() {
  String directory = sketchPath("data/icons/");
  
  File f = dataFile(directory);
  String[] names = f.list();
  
  HashMap<String, PShape> toReturn = new HashMap<String, PShape>();
  
  for(int i = 0; i < names.length; i++){
      PShape shape = loadShape(directory + names[i]);
      String keyName = names[i].substring(0, names[i].indexOf('.'));
      toReturn.put(keyName, shape);
  }
  
  println("icon dictionary size: " + toReturn.size());
  
  return toReturn;
}
