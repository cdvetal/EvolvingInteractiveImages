class Individual {
  private Node[] nodes = new Node[3];
  //private int[][] breadthTracker;
  ArrayList<Integer>[] breadthTracker = new ArrayList[3];

  int individualID;

  //algum erro com copia de individuos? ver print.

  private float fitness;

  Individual() {
    fitness = 0;
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = new Node(0);
      nodes[i].randomizeNode();
      breadthTracker[i] = new ArrayList<Integer>();
    }
    individualID = floor(random(1000000));
  }

  Individual(Node[] _nodes, ArrayList<Integer>[] _breadthTracker, float _fitness) {
    nodes = _nodes;
    breadthTracker = _breadthTracker;
    fitness = _fitness;
    individualID = floor(random(1000000));
  }

  PVector getColor(float _x, float _y, float _external) { //change back to 0 1 2
    float r = nodes[0].getValue(_x, _y, _external);
    float g = nodes[1].getValue(_x, _y, _external);
    float b = nodes[2].getValue(_x, _y, _external);

    return new PVector(r, g, b);
  }

  void identifyNodes() { //array.length is depth; val at (index) is n nodes at depth
    breadthTracker = new ArrayList[nodes.length];

    for (int i = 0; i < nodes.length; i++) {
      breadthTracker[i] = new ArrayList<Integer>();
    }

    for (int i = 0; i < nodes.length; i++) {
      nodes[i].identify(i, 0, this);
    }
  }

  int getBreadth(int _parentIndex, int _depth) {
    if (breadthTracker[_parentIndex].size() == _depth) {
      breadthTracker[_parentIndex].add(0);
    } else {
      int thisDepthBreadth = breadthTracker[_parentIndex].get(_depth);
      breadthTracker[_parentIndex].set(_depth, thisDepthBreadth + 1); //increases value at depth by one
    }

    int toReturn = breadthTracker[_parentIndex].get(_depth);

    return toReturn;
  }

  Individual crossover(Individual _partner) { //muito agressivo. tentar ir buscar node mais fundo
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

  void mutate() { //muito agressivo.
    for (int i = 0; i < nodes.length; i++)
    {
      Node node = getRandomNode(i, false);
      if (node == null) { //erros devido a copias de individuos (acho)
        println("node is null @ " + individualID);
        continue;
      }
      nodes[i].mutate();
    }
  }

  Node getRandomNode(int _index, boolean _isCopy) { //sometimes returns null.. to fix
    ArrayList<Integer> nodeBreadthTracker = breadthTracker[_index];

    int depth = floor(random(nodeBreadthTracker.size()));
    int breadth = floor(random(nodeBreadthTracker.get(depth)));

    return _isCopy ? nodes[_index].getNode(depth, breadth).getCopy() : nodes[_index].getNode(depth, breadth);
  }

  void setFitness(float _fitness) {
    fitness = _fitness;
  }

  float getFitness() {
    return fitness;
  }

  void giveFitness() {
    if (fitness >= 1) return;
    fitness += .1;
  }

  Individual getCopy() {
    Node[] copiedNodes = new Node[nodes.length];
    ArrayList<Integer>[] copiedBreadthTracker = new ArrayList[3];

    for (int i = 0; i < copiedNodes.length; i++) {
      copiedNodes[i] = nodes[i].getCopy();
      copiedBreadthTracker[i] = new ArrayList<>(breadthTracker[i]);
    }

    return new Individual(copiedNodes, copiedBreadthTracker, fitness);
  }

  PImage getPhenotype(int _resolution, float _external) {
    PGraphics canvas = createGraphics(_resolution, _resolution);

    canvas.beginDraw();

    render(canvas, _resolution, _resolution, _external);

    canvas.endDraw();

    return canvas;
  }

  void render(PGraphics _canvas, float _w, float _h, float _external) {
    for (int i = 0; i < _w; i++) {
      for (int j = 0; j < _h; j++) {
        PVector rgb = getColor((float)(i+1)/_w, (float)(j+1)/_h, _external); //+1 because of visual bug on fist line from 0 value

        color c = color(rgb.x, rgb.y, rgb.z);

        _canvas.set(i, j, c);
      }
    }
  }

  void exportImage(float _external) {
    String outputFilename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
      nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
    String outputPath = sketchPath("outputs/" + outputFilename);
    println("Exporting individual to: " + outputPath);

    getPhenotype(2000, _external).save(outputPath + ".png");
  }

  void exportAnimation() { //to do
  }
}
