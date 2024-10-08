/*

Handles the representation and manipulation of individuals.
It includes:
- Initialization of individuals
- Writting and applying shaders
- Assignment of fitness
- Mutation
- Crossover

*/

class Individual {

  private Node tree;
  PShader shader;

  int nodeHighestDepth;
  int nFullColumns = 0;

  int nChildNodes = 0;

  int individualID;

  private float fitness;

  HashMap <String, Integer> operationStats = new HashMap <String, Integer>(); //stores the number of operations in tree

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

   
   Individual(String _expression, float _fitness, Boolean _allOperations){
   tree = new Node(_expression, _allOperations);
   
   fitness = _fitness;
   }

  void cleanUp() {
    tree.checkNecessaryChildrenNodes();
    identifyNodes();
    tree.removeTooDeep();
    identifyNodes();
  }
  
  void identifyNodes() {
    nChildNodes = 0;
    nodeHighestDepth = 0;
    nFullColumns = 0;
    operationStats = new HashMap <String, Integer>();
    tree.identify(this, 0);
  }

  int getBreadth(int _depth) {

    if (_depth > nodeHighestDepth) {
      nodeHighestDepth = _depth;
    }

    return nFullColumns;
  }

  void addOperation(String _operator) {
    //if does not exist, create with value 1. if it exists add 1 to value of key
    operationStats.merge(_operator, 1, Integer::sum);
  }
  
  //node is terminal. must add breadth
  void addBreadth() {
    nFullColumns ++;
  }

  int getIndex() {
    int toReturn = nChildNodes;
    nChildNodes ++;
    return toReturn;
  }

  //creates and reads shader file
  void doShader(int _index) {
    String [] shaderLines = getShaderTextLines(tree);

    String shaderPath = sketchPath("shaders\\individuals\\shader" + _index + ".glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath, "vertShaderTemplate.glsl");
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
      if (toMutate == null) continue;
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

  void removeFitness() {
    if (fitness <= 0) return;
    fitness -= .1;
    if (fitness < 0) fitness = 0;
  }

  void giveFitness() {
    if (fitness >= 1) return;
    fitness += .1;
  }

  Individual getCopy() {
    Node copiedTree = tree.getCopy();

    return new Individual(copiedTree, fitness);
  }

  int getNChildNodes() {
    return nChildNodes;
  }

  PVector getVisDimensions() {
    return new PVector(nFullColumns, nodeHighestDepth + 1);
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

  PShader getShader() {
    return shader;
  }

  HashMap <String, Integer> getOperationStats() {
    return operationStats;
  }
}
