//gets

PImage getPhenotype(float _w, float _h, PShader _shader) {
  int w = floor(_w);
  int h = floor(_h);
  PGraphics canvas = createGraphics(w, h, P2D);

  _shader.set("resolution", _w, _h);
  _shader.set("nVariables", variablesManager.nVariables);
  _shader.set("variables", variablesManager.getShaderReadyVariables());
  _shader.set("audioSpectrum", getAudioSpectrum());
  _shader.set("image", inputImage);

  canvas.beginDraw();

  canvas.shader(_shader);

  canvas.noStroke();

  canvas.rect(0, 0, canvas.width, canvas.height);

  canvas.endDraw();

  return canvas;
}

void exportImage(Individual _individualToExport) {

  String individualFileName = _individualToExport.file;

  int lastSlashIndex = max(individualFileName.lastIndexOf('/'), individualFileName.lastIndexOf('\\'));

  String afterLastSlash = individualFileName.substring(lastSlashIndex + 1);
  

  String outputPath = sketchPath("outputs/" + afterLastSlash + "/");

  PShader exportShader = _individualToExport.getShader();

  exportCanvas.beginDraw();

  exportCanvas.clear();

  exportCanvas.shader(exportShader);

  exportCanvas.rect(0, 0, exportCanvas.width, exportCanvas.height);

  exportCanvas.endDraw();

  PImage exportImage = exportCanvas.copy();

  exportImage.save(outputPath + "img.png");
}

void setInputImage() {
  if (cam == null) return;
  if (cam.available() != true) return;

  cam.read();
  inputImage = cam;
}

float[] getAudioSpectrum() {
  float[] spectrum = new float[nBands];
  fft.analyze(spectrum);
  return spectrum;
}

//changes

void changeSong() {
  if (!songPlaying) return;

  soundFiles[soundIndex].stop();
  soundIndex ++;

  if (soundIndex >= soundFiles.length) soundIndex = 0;

  soundFiles[soundIndex].loop();
  fft.input(soundFiles[soundIndex]);
}

void muteSong() {
  if (songPlaying) soundFiles[soundIndex].stop();
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
  String directory = "shaders";
  File f = dataFile(directory);

  // Check if the directory exists
  if (f == null || !f.exists()) {
    println("Directory not found: " + directory);
    println("Ensure the shaders folder exists inside the 'data' directory.");
    exit();
  }

  // Get all shader file paths from the main directory and its subdirectories
  ArrayList<String> shaderPaths = new ArrayList<String>();
  gatherShaderFiles(f, shaderPaths);

  // Check if the shaderPaths list is not empty
  if (shaderPaths.isEmpty()) {
    println("No evolved shaders found");
    println("Place the evolved shaders inside data/shaders folder or its subdirectories");
    exit();
  }

  Individual[] individualsToReturn = new Individual[shaderPaths.size()];

  for (int i = 0; i < shaderPaths.size(); i++) {
    PShader shader = loadShader(shaderPaths.get(i), "vertShaderTemplate.glsl");
    String shaderName = shaderPaths.get(i).replace(directory + "/", "");
    individualsToReturn[i] = new Individual(shader, shaderName);
  }

  return individualsToReturn;
}

// Helper function to recursively gather shader files
void gatherShaderFiles(File dir, ArrayList<String> shaderPaths) {
  File[] files = dir.listFiles();

  for (File file : files) {
    if (file.isDirectory()) {
      // Recursively gather shaders from subdirectories
      gatherShaderFiles(file, shaderPaths);
    } else if (file.getName().endsWith(".glsl")) {
      // Add shader file path if it has the .glsl extension
      shaderPaths.add(file.getAbsolutePath());
    }
  }
}
