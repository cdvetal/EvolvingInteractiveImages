class Individual {

  private Node tree;
  PShader shader;
  ArrayList<Integer> breadthTracker = new ArrayList<Integer>();
  int highestVisX = 0;

  int nChildNodes = 0;

  int individualID;

  private float fitness;

  Individual() {
    fitness = 0;

    tree = new Node(0);
    tree.randomizeNode(true);
    cleanUp();
    
    generateID();
  }

  Individual(Node _tree, float _fitness) {
    tree = _tree;
    fitness = _fitness;
    cleanUp();
    generateID();
  }
  
  /*
  //under maintnance
  Individual(String[] _expressions, float _fitness){
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = new Node(_expressions[i]);
    }
    
    fitness = _fitness;
  }*/
  
  void cleanUp(){
     tree.removeUnusedNodes();
     identifyNodes(); 
  }

  void identifyNodes() {
    nChildNodes = 0;
    breadthTracker = new ArrayList<Integer>();
    tree.identify(this);
  }
  
  String[] getExpressions(){
   String[] expressions = new String[3];
   
   for(int i = 0; i < expressions.length; i++){
     expressions[i] = tree.getFunctionString(i);
   }
   
   return expressions;
  }

  String[] getShaderTextLines() {
    String[] shaderLines = templateShaderLines.clone();
    
    String[] expressions = getExpressions();

    shaderLines[shaderChangeLineStart - 1] = "    float r = " + expressions[0] + ";";
    shaderLines[shaderChangeLineStart    ] = "    float g = " + expressions[1] + ";";
    shaderLines[shaderChangeLineStart + 1] = "    float b = " + expressions[2] + ";";

    return shaderLines;
  }

  void doShader(int _index) {
    String [] shaderLines = getShaderTextLines();

    String shaderPath = sketchPath("shaders\\shader" + _index + ".glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath);
  }

  int getBreadth(int _depth) {
    if(_depth < breadthTracker.size()){
       breadthTracker.set(_depth,breadthTracker.get(_depth) + 1);
    } else if (_depth == breadthTracker.size()){
      breadthTracker.add(0);
    } else {
     print("ERROR"); 
    }

    return breadthTracker.get(_depth);
  }

  int getIndex() {
    nChildNodes ++;
    return nChildNodes - 1;
  }

  Individual crossover(Individual _partner) {
    Individual child = getCopy();
    
    Node partnerNodeCopy = _partner.getRandomNode(true);
    
    child.replaceRandomNode(partnerNodeCopy);

    return child;
  }

  void mutate() {

    for (int i = 0; i < nChildNodes; i++) {
      if (random(1) > mutationRate) continue;
      Node toMutate = tree.getNode(i);
      if(toMutate == null) continue;
      toMutate.mutate();
    }
    
    identifyNodes();
    
    if (random(1) < mutationRate) replaceRandomNode(createRandomNode());
    
    generateID();
  }

  Node getRandomNode(boolean _isCopy) {

    int randomNodeIndex = floor(random(nChildNodes));

    Node randomNode = tree.getNode(randomNodeIndex);

    return _isCopy ? randomNode.getCopy() : randomNode;
  }
  
  Node createRandomNode() {
    Node randomNode = new Node(0);
    randomNode.randomizeNode(true);
    
    return randomNode;
    
  }

  void replaceRandomNode(Node _newNode) {
    int randomNodeIndex = floor(random(nChildNodes));

    tree.replaceNode(randomNodeIndex, _newNode);
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
    Node copiedTree = tree.getCopy();

    return new Individual(copiedTree, fitness);
  }

  PImage getPhenotype(float _w, float _h, float _external, float[] _audioSpectrum) {
    int w = floor(_w);
    int h = floor(_h);
    PGraphics canvas = createGraphics(w, h, P2D);

    canvas.beginDraw();

    render(canvas, w, h, _external, _audioSpectrum);

    canvas.endDraw();

    return canvas;
  }

  void render(PGraphics _canvas, int _w, int _h, float _external, float[] _audioSpectrum) {
    PImage image = new PImage(_w, _h, RGB);

    //shader.set("resolution", _w, _h); //doesnt matter
    shader.set("externalVal", _external);
    shader.set("audioSpectrum", _audioSpectrum);
    shader.set("image", inputImage);
    
    _canvas.shader(shader);
    _canvas.image(image, 0, 0);
  }

  int getNChildNodes() {
    return nChildNodes;
  }
  
  PVector getVisDimensions(){
    return new PVector(breadthTracker.get(breadthTracker.size() - 1) + 1, breadthTracker.size() + 1);
  }
  
  Node getTreeCopy() {
    return tree.getCopy();
  }

  void generateID() {
    individualID = floor(random(10000000));
  }

  int getID() {
    return individualID;
  }
}
