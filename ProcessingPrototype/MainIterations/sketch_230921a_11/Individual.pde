class Individual {
  private Node[] nodes = new Node[3];
  PShader shader;
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
    generateID();
  }

  Individual(Node[] _nodes, int[] _nChildNodes, float _fitness) {
    nodes = _nodes;
    nChildNodes = _nChildNodes;
    fitness = _fitness;
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
    Individual child = new Individual();

    for (int i = 0; i < nodes.length; i++) {
      Node partnerNodeCopy = _partner.getRandomNode(i, true);

      replaceRandomNode(i, partnerNodeCopy);
    }

    return child;
  }

  void mutate() {
    for (int i = 0; i < nodes.length; i++)
    {
      Node node = getRandomNode(i, false);
      if (node == null) {
        println("node is null @ " + individualID);
        continue;
      }
      node.mutate();
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
    println("");
    for (int i = 0; i < nodes.length; i++) {
      println(nodes[i].getFunctionString());
    }
  }

  Individual getCopy() {
    Node[] copiedNodes = new Node[nodes.length];

    for (int i = 0; i < copiedNodes.length; i++) {
      copiedNodes[i] = nodes[i].getCopy();
    }

    return new Individual(copiedNodes, nChildNodes.clone(), fitness);
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

  void exportImage(float _external) {
    String outputFilename = year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" +
      nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2);
    String outputPath = sketchPath("outputs/" + outputFilename);
    println("Exporting individual to: " + outputPath);

    getPhenotype(imageExportResolution, _external).save(outputPath + ".png");
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
