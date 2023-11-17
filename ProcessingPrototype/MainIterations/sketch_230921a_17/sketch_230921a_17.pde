import java.util.*;
import processing.pdf.*;
import processing.sound.*;

PImage exampleImage;

int populationSize = 20;
int eliteSize = 2;
int tournamentSize = 3;
float crossoverRate = .5;
float mutationRate = .4;

int maxDepth = 30;
int resolution = 150;
int imageExportResolution = 1920;
int animationExportResolution = 1440;

boolean externalMode;
float minExternal = 0.001;
float maxExternal = 0.999;

FFT fft;
SoundFile[] soundFiles;
boolean muted = true;
int nBands = 512;
int soundIndex = 0;

Run run;

Population population;

PVector[][] grid;
float aspectRatio = 1.8; //width = height * aspectRatio
Individual hoveredIndividual = null;

boolean isExportingAnimation;
int nAnimationFrames = 96;

Operation[] operations;
String[] templateShaderLines;
int shaderChangeLineStart = 91; //3 lines need changing (r,g,b), first line is this (as shown in vscode)

Button pressedButton;

int screen = 0; //0 - main menu, 1 - load, 2 - evolving

MainMenu mainMenu;
LoadMenu loadMenu;

void setup() {
  size(1000, 1000, P2D);
  //fullScreen(P2D);
  colorMode(RGB, 1);

  exampleImage = loadImage("shells.jpg");

  fft = new FFT(this, nBands);
  soundFiles = loadSongs();
  changeSong();

  operations = setupOperations();
  templateShaderLines = loadStrings("shaderTemplate.glsl");

  run = new Run();
  run.startRun();
  population = new Population();

  mainMenu = new MainMenu();
  loadMenu = new LoadMenu();

  grid = calculateGrid(populationSize, 0, 0, width, height, 10, 10, 10, false);
  resolution = min(resolution, (int)grid[0][0].z);
}

void draw() {
  background(.05);
  switch(screen) {
    case(0):
    mainMenu.run();
    break;

    case(1):
    loadMenu.run();
    break;

    case(2):
    float externalValue = getExternalValue();
    float[] audioSpectrum = getAudioSpectrum();
    hoveredIndividual = getHoveredIndividual();
    if (hoveredIndividual != null) {
      drawIndividualFullScreen(hoveredIndividual, externalValue, audioSpectrum);
    } else {
      drawPopulation(externalValue, audioSpectrum);
    }
    drawExternalFeedback(externalValue);
    break;
  }
}

float[] getAudioSpectrum() {
  float[] spectrum = new float[nBands];
  fft.analyze(spectrum);
  return spectrum;
}

float getExternalValue() {
  float toReturn;

  if (externalMode) toReturn = map(mouseX, 0, width, minExternal, maxExternal);
  else toReturn = map(sin((float)millis()/1000), -1, 1, minExternal, maxExternal);

  return toReturn;
}

void drawExternalFeedback(float _external) {
  noStroke();

  if (_external > 0) fill(0, 1, 0);
  else fill(1, 0, 0);

  circle(width - 20, height - 20, _external * 20);

  fill(1);
  textAlign(LEFT, CENTER);
  text(_external, width - 80, height - 20);
}

void drawIndividualFullScreen(Individual _indiv, float _external, float[] _audioSpectrum) {
  float windowAspectRatio = width / height;
  if (windowAspectRatio < aspectRatio) {
    float h = width/aspectRatio;
    float y = (height - h) / 2;
    image(_indiv.getPhenotype(width, h, _external, _audioSpectrum), 0, y, width, h);
  } else {
    float w = height * aspectRatio;
    float x = (width - w) / 2;
    image(_indiv.getPhenotype(w, height, _external, _audioSpectrum), x, 0, w, height);
  }
}

void drawPopulation(float _external, float[] _audioSpectrum) {
  int row = 0, col = 0;

  float d = grid[0][0].z, h = grid[0][0].z, w = grid[0][0].z;
  float shift;

  if (aspectRatio > 1) {
    h = d/aspectRatio;
    shift = (d-h) / 2;
  } else {
    w = d*aspectRatio;
    shift = (d-w) / 2;
  }

  for (int i = 0; i < population.getSize(); i++) {
    float x = grid[row][col].x;
    float y = grid[row][col].y;
    noFill();

    if (aspectRatio > 1) {
      image(population.getIndividual(i).getPhenotype(d, h, _external, _audioSpectrum), x, y + shift, d, h);
    } else {
      image(population.getIndividual(i).getPhenotype(w, d, _external, _audioSpectrum), x + shift, y, w, d);
    }

    /*if (mouseX > x && mouseX < x + d && mouseY > y && mouseY < y + d) {
     hoveredIndividual = population.getIndividual(i);
     noStroke();
     fill(1, .5);
     rect(x, y, d, d);
     
     fill(1);
     text(hoveredIndividual.getTotalChildNodes(), 20, 20);
     }*/
    if (population.getIndividual(i).getFitness() > 0) {
      stroke(1);
      strokeWeight(map(population.getIndividual(i).getFitness(), 0, 1, 3, 6));
      if (aspectRatio > 1) {
        rect(x, y + shift, d, h);
      } else {
        rect(x + shift, y, w, d);
      }
    }

    col += 1;
    if (col >= grid[row].length) {
      row += 1;
      col = 0;
    }
  }
}

Individual getHoveredIndividual() {
  int row = 0, col = 0;
  hoveredIndividual = null;

  float d = grid[0][0].z, h = grid[0][0].z, w = grid[0][0].z;
  float shift;
  if (aspectRatio > 1) {
    h = d/aspectRatio;
    shift = (d-h) / 2;
  } else {
    w = d*aspectRatio;
    shift = (d-w) / 2;
  }

  for (int i = 0; i < population.getSize(); i++) {
    float x = grid[row][col].x;
    float y = grid[row][col].y;


    if (aspectRatio > 1 && mouseX > x && mouseX < x + d && mouseY > y + shift && mouseY < y + shift + h) {
      return population.getIndividual(i);
    } else if (aspectRatio <= 1 && mouseX > x + shift && mouseX < x + shift + w && mouseY > y && mouseY < y + d) {
      return population.getIndividual(i);
    }

    col += 1;
    if (col >= grid[row].length) {
      row += 1;
      col = 0;
    }
  }

  return null;
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

void mousePressed() {
  if (isExportingAnimation) return;

  if (hoveredIndividual == null) return;
  if (mouseButton == LEFT) hoveredIndividual.giveFitness();
  if (mouseButton == RIGHT) hoveredIndividual.setFitness(0);
}

void keyPressed() {
  /*if (key==27) {
   key=0;
   }*/

  if (isExportingAnimation) return;

  if (key == ' ') {
    population.evolve();
  }

  if (key == 'E' || key == 'e') {
    externalMode = !externalMode;
  }

  if (key == 'A' || key == 'a') {
    muted =! muted;
    muteSong();
  }

  if (key == 'M' || key == 'm') {
    changeSong();
  }

  if (hoveredIndividual == null) return;

  if (key == 'S' || key == 's') {
    exportShader(hoveredIndividual);
    exportImage(hoveredIndividual);
  }
}

void mouseReleased() {
  if (pressedButton == null) return;
  pressedButton.selected();
  pressedButton = null;
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

String[] splitStringAtIndex(String _string, int _index) {
  String[] toReturn = new String[2];

  if (_index <= 0) println("index " + _index + " too small at splitStringAtIndex");
  if (_index >= _string.length()) println("index " + _index + " too large at splitStringAtIndex with string: " + _string);

  toReturn[0] = _string.substring(0, _index);
  toReturn[1] = _string.substring(_index+1);

  return toReturn;
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
