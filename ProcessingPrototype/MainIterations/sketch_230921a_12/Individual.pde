class Individual {
  private Node[] nodes = new Node[3];
  PShader shader;
  //private int[][] breadthTracker;
  ArrayList<Integer>[] breadthTracker = new ArrayList[3];

  int[] nChildNodes = new int[3];

  int individualID;

  private float fitness;

  Individual() {
    fitness = 0;
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = new Node(0);
      nodes[i].randomizeNode();
      nChildNodes[i] = 0;
    }
    generateID();
  }

  Individual(Node[] _nodes, float _fitness) {
    nodes = _nodes;
    fitness = _fitness;
    identifyNodes();
    generateID();
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

  String[] getShaderTextLines() {
    String[] shaderLines = templateShaderLines.clone();

    shaderLines[shaderChangeLineStart - 1] = "    float r = " + nodes[0].getFunctionString() + ";";
    shaderLines[shaderChangeLineStart    ] = "    float g = " + nodes[1].getFunctionString() + ";";
    shaderLines[shaderChangeLineStart + 1] = "    float b = " + nodes[2].getFunctionString() + ";";

    return shaderLines;
  }

  void doShader(int _index) {
    String [] shaderLines = getShaderTextLines();

    String shaderPath = sketchPath("shaders\\shader" + _index + ".glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath);
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

  Individual crossover(Individual _partner) {
    Individual child = getCopy();

    for (int i = 0; i < nodes.length; i++) {
      Node partnerNodeCopy = _partner.getRandomNode(i, true);

      child.replaceRandomNode(i, partnerNodeCopy);
    }

    return child;
  }

  void mutate() {
    for (int i = 0; i < nodes.length; i++)
    {
      for (int j = 0; j < nChildNodes[i]; j++) {
        if (random(1) < mutationRate) nodes[i].getNode(j).mutate();
      }
    }

    generateID();
  }

  Node getRandomNode(int _index, boolean _isCopy) {

    int randomNodeIndex = floor(random(nChildNodes[_index]));

    Node randomNode = nodes[_index].getNode(randomNodeIndex);

    return _isCopy ? randomNode.getCopy() : randomNode;
  }

  void replaceRandomNode(int _index, Node _newNode) {
    int randomNodeIndex = floor(random(nChildNodes[_index]));

    nodes[_index].replaceNode(randomNodeIndex, _newNode);
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

    return new Individual(copiedNodes, fitness);
  }

  PImage getPhenotype(int _resolution, float _external) {
    PGraphics canvas = createGraphics(_resolution, _resolution, P2D);

    canvas.beginDraw();

    render(canvas, _resolution, _resolution, _external);

    canvas.endDraw();

    return canvas;
  }

  void render(PGraphics _canvas, int _w, int _h, float _external) {
    PImage image = new PImage(_w, _h, RGB);

    //shader.set("resolution", _w, _h); //doesnt matter
    shader.set("externalVal", _external);
    _canvas.shader(shader);
    _canvas.image(image, 0, 0);
  }

  int[] getNChildNodes() {
    return nChildNodes;
  }

  int getTotalChildNodes() {
    int toReturn = 0;

    for (int i = 0; i < nChildNodes.length; i++) {
      toReturn += nChildNodes[i];
    }

    return toReturn;
  }

  void generateID() {
    individualID = floor(random(10000000));
  }

  int getID() {
    return individualID;
  }
}
