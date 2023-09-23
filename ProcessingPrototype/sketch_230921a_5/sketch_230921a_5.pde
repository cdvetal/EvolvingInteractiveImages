int populationSize = 20;
int eliteSize = 2;
int tournamentSize = 3;
float crossoverRate = .6;
float mutationRate = .2;

int maxDepth = 40;
int maxNodeChildren = 4;
int resolution = 150;

Population population;
PVector[][] grid;
Individual hoveredIndividual = null;

void setup() {
  size(1440, 920);
  colorMode(RGB, 1);

  population = new Population();
  grid = calculateGrid(populationSize, 0, 0, width, height, 20, 20, 20, false);
}

void draw() {
  background(.05);
  drawPopulation();
}

void drawPopulation() {
  int row = 0, col = 0;
  for (int i = 0; i < population.getSize(); i++) {
    float x = grid[row][col].x;
    float y = grid[row][col].y;
    float d = grid[row][col].z;
    noFill();

    image(population.getIndividual(i).getPhenotype(resolution), x, y, d, d);

    if (mouseX > x && mouseX < x + d && mouseY > y && mouseY < y + d) {
      hoveredIndividual = population.getIndividual(i);
      noStroke();
      fill(1, .5);
      rect(x, y, d, d);
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

void mousePressed(){
  if (hoveredIndividual == null) return;
  if(mouseButton == LEFT) hoveredIndividual.giveFitness();
  if(mouseButton == RIGHT) hoveredIndividual.setFitness(0);
}

void keyPressed() {
  if (key == ' ') {
    population.evolve();
  }

  if (keyCode != ENTER || hoveredIndividual == null) return;
  println("saved image");
  hoveredIndividual.export();
}
