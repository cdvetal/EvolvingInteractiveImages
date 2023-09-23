import processing.pdf.*;

class Individual {
  Node[] nodes = new Node[3];
  int[] breadthTracker;

  float fitness;

  Individual() {
    fitness = 0;
    breadthTracker = new int[maxDepth];
    for (int i = 0; i < 3; i++) {
      nodes[i] = new Node(this);
      nodes[i].randomizeNode(this);
    }
    identifyNodes();
  }

  Individual(Node[] _nodes, int[] _breadthTracker, float _fitness) {
    nodes = _nodes;
    breadthTracker = _breadthTracker;
    fitness = _fitness;
  }

  PVector getColor(float _x, float _y) {
    float r = nodes[0].getValue(_x, _y);
    float g = nodes[1].getValue(_x, _y);
    float b = nodes[2].getValue(_x, _y);

    return new PVector(r, g, b);
  }

  int getNextBreadth(int _depth) {
    int toReturn = breadthTracker[_depth];
    breadthTracker[_depth] ++;
    return toReturn;
  }

  void identifyNodes() {
    breadthTracker = new int[maxDepth];
    for (int i = 0; i < 3; i++) {
      nodes[i].identify(0, this);
    }
  }

  Individual crossover(Individual _partner) { //muito agressivo. tentar trocar nodes mais fundo
    Individual child = new Individual();

    int crossoverPoint = int(random(1, child.nodes.length -1));

    for (int i = 0; i < child.nodes.length; i++) {
      if (i < crossoverPoint) {
        child.nodes[i] = this.nodes[i];
      } else {
        child.nodes[i] = _partner.nodes[i];
      }
    }

    return child;
  }

  void mutate() {
    for (int i = 0; i < nodes.length; i++)
    {
      nodes[i].mutate(this);
    }
  }

  void setFitness(float _fitness) {
    fitness = _fitness;
  }

  float getFitness() {
    return fitness;
  }
  
  void giveFitness(){
    if(fitness >= 1) return;
     fitness += .1; 
  }

  Individual getCopy() {
    Node[] copiedNodes = new Node[nodes.length];
    for(int i = 0; i < copiedNodes.length; i++){
      copiedNodes[i] = nodes[i].getCopy();
    }
    return new Individual(copiedNodes, breadthTracker, fitness);
  }
  
  PImage getPhenotype(int _resolution) {
    PGraphics canvas = createGraphics(_resolution, _resolution);
    
    canvas.beginDraw();

    render(canvas, _resolution, _resolution);

    canvas.endDraw();
    
    return canvas;
  }
  
  void render(PGraphics _canvas, float _w, float _h) {
    for (int i = 0; i < _w; i++) {
      for (int j = 0; j < _h; j++) {
        PVector rgb = getColor((float)i/_w, (float)j/_h);

        color c = color(rgb.x, rgb.y, rgb.z);

        _canvas.set(i, j, c);
      }
    }
  }
  
  void export() {
    String outputFilename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
                             nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
    String outputPath = sketchPath("outputs/" + outputFilename);
    println("Exporting individual to: " + outputPath);
    
    getPhenotype(2000).save(outputPath + ".png");
  }
}
