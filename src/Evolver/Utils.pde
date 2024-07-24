void exportImage(Individual _individualToExport) {

  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");

  PShader exportShader = _individualToExport.getShader();

  //exportShader.set("nVariables", variablesManager.nVariables);
  //exportShader.set("variables", variablesManager.getShaderReadyVariables());
  //exportShader.set("audioSpectrum", getAudioSpectrum());
  //exportShader.set("image", inputImage);

  exportCanvas.beginDraw();

  exportCanvas.clear();

  exportCanvas.shader(exportShader);

  exportCanvas.rect(0, 0, exportCanvas.width, exportCanvas.height);

  exportCanvas.endDraw();

  PImage exportImage = exportCanvas.copy();

  //PImage image = getPhenotype(imageExportResolution, imageExportResolution, _individualToExport.getShader(), variablesManager.getShaderReadyVariables(), getAudioSpectrum());
  //image.save(outputPath + "img.png");

  exportImage.save(outputPath + "img.png");

  popup.setPopup("Exported");
}

void exportShader(Individual _individualToExport) {
  exportShader(_individualToExport.tree, "" + _individualToExport.getID());
}

void exportShader(Node _node, String _name) {
  String outputPath = sketchPath("outputs/" + _name + "/");
  String[] shaderStrings = getShaderTextLines(_node);
  
  String dateComment = "// ";
  dateComment += year() + " - " + month() + " - " + day();
  
  String algorithmComment = "// ";
  algorithmComment += "Population Size: " + populationSize + "; Elite Size: " + eliteSize + "; Mutation Rate: " + mutationRate + "; Crossover Rate: " + crossoverRate + "; Tournament Size: " + tournamentSize;
  
  shaderStrings[3] = dateComment;
  shaderStrings[5] = "// Generation: " + population.nGenerations;
  shaderStrings[6] = algorithmComment;
  
  saveStrings(outputPath + _name + ".glsl", shaderStrings);
}

void exportTreeShader(Node _node, String _name) {
  String outputPath = sketchPath("shaders/tree/");
  saveStrings(outputPath + _name + ".glsl", getShaderTextLines(_node));
}

String[] getShaderTextLines(Node _node) {
  String[] shaderLines = fragShaderTemplateLines.clone();

  String[] expressions = _node.getExpressions();

  shaderLines[shaderChangeLineStart] =     "    float r = " + expressions[0] + ";";
  shaderLines[shaderChangeLineStart + 1] = "    float g = " + expressions[1] + ";";
  shaderLines[shaderChangeLineStart + 2] = "    float b = " + expressions[2] + ";";

  return shaderLines;
}

PImage getPhenotype(float _w, float _h, PShader _shader, float[] _variables, float[] _audioSpectrum) {
  int w = floor(_w);
  int h = floor(_h);
  PGraphics canvas = createGraphics(w, h, P2D);

  _shader.set("nVariables", _variables.length);
  _shader.set("variables", _variables);
  _shader.set("audioSpectrum", _audioSpectrum);
  _shader.set("image", inputImage);

  canvas.beginDraw();

  canvas.shader(_shader);

  canvas.rect(0, 0, canvas.width, canvas.height);

  canvas.endDraw();

  return canvas;
}

void drawPhenotype(float _x, float _y, float _w, float _h, PShader _shader, float[] _variables, float[] _audioSpectrum) {
  int w = floor(_w);
  int h = floor(_h);

  _shader.set("nVariables", _variables.length);
  _shader.set("variables", _variables);
  _shader.set("audioSpectrum", _audioSpectrum);
  _shader.set("image", inputImage);

  shader(_shader);
  noStroke();
  rect(_x, _y, w, h);
  resetShader();
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

int calculateLineToChangeInShader(String[] _shaderTemplateStrings) {
  String lineStartString = "float r = ";
  
  for (int i = 0; i < _shaderTemplateStrings.length; i ++) {
    if (_shaderTemplateStrings[i].indexOf(lineStartString) >= 0) {
      println("line: "+ i);
      return i;
    }
  }
  return 0;
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
  muted =! muted;
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

  for (int i = 0; i < names.length; i++) {
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

  for (int i = 0; i < strings.length; i++) {
    String[] colorPair = strings[i].split("_");
    String keyName = colorPair[0];
    String colorHex = "FF" + colorPair[1]; //FF means it's opaque
    color c = unhex(colorHex);
    toReturn.put(keyName, c);
  }

  return toReturn;
}

HashMap<String, PFont> loadFonts() {
  String directory = sketchPath("data/fonts/");

  File f = dataFile(directory);
  String[] names = f.list();

  HashMap<String, PFont> toReturn = new HashMap<String, PFont>();

  for (int i = 0; i < names.length; i++) {
    PFont font = createFont(directory + names[i], 128);
    String keyName = names[i].substring(0, names[i].indexOf('.'));
    toReturn.put(keyName, font);
  }

  return toReturn;
}

PVector[] setupColumns(int _nColumns) {

  PVector[] toReturn = new PVector[_nColumns];

  int widthNoBorder = width - border - border;
  int widthGaps = (_nColumns - 1) * gap;
  float columnWidth = (widthNoBorder - widthGaps) / _nColumns;

  int currentX = border;

  for (int i = 0; i < _nColumns; i++) {
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

String[] splitStringAtIndex(String _string, int _index) {
  String[] toReturn = new String[2];

  if (_index <= 0) println("index " + _index + " too small at splitStringAtIndex");
  if (_index >= _string.length()) println("index " + _index + " too large at splitStringAtIndex with string: " + _string);

  toReturn[0] = _string.substring(0, _index);
  toReturn[1] = _string.substring(_index+1);

  return toReturn;
}
