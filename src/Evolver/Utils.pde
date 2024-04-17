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
  
  return toReturn;
}

HashMap<String, Integer> loadColors() {
  String directory = sketchPath("data/colors.txt");
  
  String[] strings = loadStrings(directory);
  
  HashMap<String, Integer> toReturn = new HashMap<String, Integer>();
  
  for(int i = 0; i < strings.length; i++){
    String[] colorPair = strings[i].split("_");
    String keyName = colorPair[0];
    String colorHex = "FF" + colorPair[1]; //FF means it's opaque
    color c = unhex(colorHex);
    toReturn.put(keyName, c);
  }
  
  return toReturn;
}

HashMap<String, PFont> loadFonts(){
  String directory = sketchPath("data/fonts/");
  
  File f = dataFile(directory);
  String[] names = f.list();
  
  HashMap<String, PFont> toReturn = new HashMap<String, PFont>();
  
  for(int i = 0; i < names.length; i++){
      PFont font = createFont(directory + names[i], 128);
      String keyName = names[i].substring(0, names[i].indexOf('.'));
      toReturn.put(keyName, font);
  }
  
  return toReturn;
}

PVector[] setupColumns(int _nColumns){
  
  PVector[] toReturn = new PVector[_nColumns];
  
  int widthNoBorder = width - border - border;
  int widthGaps = (_nColumns - 1) * gap;
  float columnWidth = (widthNoBorder - widthGaps) / _nColumns;
  
  int currentX = border;
  
  for(int i = 0; i < _nColumns; i++){
    float xA = currentX;
    currentX += columnWidth;
    toReturn[i] = new PVector(xA, currentX, columnWidth);
    currentX += gap;
  }
  
  return toReturn;
}

PVector[][] calculateGrid(int cells, float x, float y, float w, float h, float margin_min, float gutter_h, float gutter_v, boolean align_top) {
  if (cells <= 0) return null;
  int cols = 0, rows = 0;
  float cell_size = 0;
  while (cols * rows < cells) {
    cols += 1;
    cell_size = ((w - margin_min * 2) - (cols - 1) * gutter_h) / cols;
    rows = floor((h - margin_min * 2) / (cell_size + gutter_v));
  }
  if (cols * (rows - 1) >= cells) {
    rows -= 1;
  }
  float margin_hor_adjusted = ((w - cols * cell_size) - (cols - 1) * gutter_h) / 2;
  if (rows == 1 && cols > cells) {
    margin_hor_adjusted = ((w - cells * cell_size) - (cells - 1) * gutter_h) / 2;
  }
  float margin_ver_adjusted = ((h - rows * cell_size) - (rows - 1) * gutter_v) / 2;
  if (align_top) {
    margin_ver_adjusted = min(margin_hor_adjusted, margin_ver_adjusted);
  }
  PVector[][] positions = new PVector[rows][cols];
  for (int row = 0; row < rows; row++) {
    float row_y = y + margin_ver_adjusted + row * (cell_size + gutter_v);
    for (int col = 0; col < cols; col++) {
      float col_x = x + margin_hor_adjusted + col * (cell_size + gutter_h);
      positions[row][col] = new PVector(col_x, row_y, cell_size);
    }
  }
  return positions;
}
