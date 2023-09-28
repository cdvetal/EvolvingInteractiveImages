class Individual {
  private Node[] nodes = new Node[3];
  //private int[][] breadthTracker;
  ArrayList<Integer>[] breadthTracker = new ArrayList[3];

  int[] nChildNodes = new int[3];

  int individualID;

  //algum erro com copia de individuos? ver print.

  private float fitness;

  Individual() {
    fitness = 0;
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = new Node(0);
      nodes[i].randomizeNode();
      nChildNodes[i] = 0;
    }
    individualID = floor(random(1000000));
  }

  Individual(Node[] _nodes, int[] _nChildNodes, float _fitness) {
    nodes = _nodes;
    nChildNodes = _nChildNodes;
    fitness = _fitness;
    individualID = floor(random(1000000));
  }

  PVector getColor(float _x, float _y, float _external) { //change back to 0 1 2
    float r = nodes[0].getValue(_x, _y, _external);
    float g = nodes[1].getValue(_x, _y, _external);
    float b = nodes[2].getValue(_x, _y, _external);

    return new PVector(r, g, b);
  }

  void identifyNodes() {

    for (int i = 0; i < nodes.length; i++) {
      nChildNodes[i] = 0;
    }

    for (int i = 0; i < nodes.length; i++) {
      nodes[i].identify(i, this);
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

  int getIndex(int _parentIndex) {
    nChildNodes[_parentIndex] ++;
    return nChildNodes[_parentIndex] - 1;
  }

  Individual crossover(Individual _partner) { //random node, from each partner, from each parent node > switch them
    Individual child = new Individual();

    for (int i = 0; i < nodes.length; i++) {
      Node thisNode = getRandomNode(i, false);
      Node thisNodeCopy = thisNode.getCopy();

      Node partnerNode = _partner.getRandomNode(i, false);

      thisNode = partnerNode.getCopy();
      partnerNode = thisNodeCopy;
    }

    return child;
  }

  void mutate() { //muito agressivo.
    for (int i = 0; i < nodes.length; i++)
    {
      Node node = getRandomNode(i, false);
      if (node == null) {
        println("node is null @ " + individualID);
        continue;
      }
      node.mutate();
    }
  }

  Node getRandomNode(int _index, boolean _isCopy) {

    int randomNodeIndex = floor(random(nChildNodes[_index]));

    Node randomNode = nodes[_index].getNode(randomNodeIndex);

    return _isCopy ? randomNode.getCopy() : randomNode;
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

    for (int i = 0; i < copiedNodes.length; i++) {
      copiedNodes[i] = nodes[i].getCopy();
    }

    return new Individual(copiedNodes, nChildNodes.clone(), fitness);
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

  int[] getNChildNodes() {
    return nChildNodes;
  }
  
  int getTotalChildNodes(){
     int toReturn = 0;
     
     for(int i = 0; i < nChildNodes.length; i++){
       toReturn += nChildNodes[i];
     }
     
     return toReturn;
  }
}
