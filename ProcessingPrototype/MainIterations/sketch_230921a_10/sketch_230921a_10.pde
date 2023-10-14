import java.util.*;
import processing.pdf.*;

int populationSize = 20;
int eliteSize = 2;
int tournamentSize = 3;
float crossoverRate = .6;
float mutationRate = .2;

int maxDepth = 30;
int resolution = 150;
int imageExportResolution = 1920;
int animationExportResolution = 1440;

boolean externalMode;
int minExternal = 0;
int maxExternal = 1;

Population population;
PVector[][] grid;
Individual hoveredIndividual = null;

boolean isExportingAnimation;
int nAnimationFrames = 96;

Operation[] operations;
String[] templateShaderLines;
int shaderChangeLineStart = 48; //3 lines need changing (r,g,b), first line is this

void setup() {
  size(1080, 1080, P2D);
  colorMode(RGB, 1);

  operations = setupOperations();
  templateShaderLines = loadStrings("shaderTemplate.glsl");
  
  population = new Population();
  grid = calculateGrid(populationSize, 0, 0, width, height, 10, 10, 10, false);
}

void draw() {
  background(.05);
  float externalValue = getExternalValue();
  drawPopulation(externalValue);
  drawExternalFeedback(externalValue);
}

float getExternalValue() {
  float toReturn;

  if (externalMode) toReturn = map(mouseX, 0, width, minExternal, maxExternal);
  else toReturn = map(sin((float)millis()/1000), -1, 1, minExternal, maxExternal) + 0.01;

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

void drawPopulation(float _external) {
  int row = 0, col = 0;
  for (int i = 0; i < population.getSize(); i++) {
    float x = grid[row][col].x;
    float y = grid[row][col].y;
    float d = grid[row][col].z;
    noFill();

    image(population.getIndividual(i).getPhenotype(resolution, _external), x, y, d, d);

    if (mouseX > x && mouseX < x + d && mouseY > y && mouseY < y + d) {
      hoveredIndividual = population.getIndividual(i);
      noStroke();
      fill(1, .5);
      rect(x, y, d, d);

      fill(1);
      text(hoveredIndividual.getTotalChildNodes(), 20, 20);
    }
    if (population.getIndividual(i).getFitness() > 0) {
      stroke(1);
      strokeWeight(map(population.getIndividual(i).getFitness(), 0, 1, 3, 6));
      rect(x, y, d, d);
    }

    col += 1;
    if (col >= grid[row].length) {
      row += 1;
      col = 0;
    }
  }
}

PVector[][] calculateGrid(int cells, float x, float y, float w, float h, float margin_min, float gutter_h, float gutter_v, boolean align_top) {
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

void exportAnimation(Individual _individualToExport) {
  int millisStarted = millis();
  int previousMillis = millisStarted;
  isExportingAnimation = true;
  println("Started exporting animation. Sit tight.");

  String outputPath = sketchPath("outputs/" + _individualToExport.getID() + "/");

  float sinInc = (float)(Math.PI*2) / nAnimationFrames;

  for (int i = 0; i < nAnimationFrames; i++) {
    float currentAnimationExternal = map(sin(sinInc * i), -1, 1, minExternal, maxExternal) + 0.001;
    String fileName = nf(i, 5);
    String currentOutputPath = outputPath + fileName;
    _individualToExport.getPhenotype(animationExportResolution, currentAnimationExternal).save(currentOutputPath + ".png");
    
    int thisFrameMillis = millis() - previousMillis;
    println(currentAnimationExternal + "  " + (i+1) + " / " + nAnimationFrames + "  " + thisFrameMillis + "ms");
    previousMillis = millis();
  }
  
  saveStrings(outputPath + "shader.glsl", _individualToExport.getShaderTextLines());
  
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

void mousePressed() {
  if (isExportingAnimation) return;

  if (hoveredIndividual == null) return;
  if (mouseButton == LEFT) hoveredIndividual.giveFitness();
  if (mouseButton == RIGHT) hoveredIndividual.setFitness(0);
}

void keyPressed() {
  if (isExportingAnimation) return;

  if (key == ' ') {
    population.evolve();
  }

  if (key == 'E' || key == 'e') {
    externalMode = !externalMode;
  }

  if (hoveredIndividual == null) return;

  if (keyCode == ENTER) {
    println("saved image");
    hoveredIndividual.exportImage(getExternalValue());
  }

  if (key == 'A' || key == 'a') {
    exportAnimation(hoveredIndividual);
  }
}
