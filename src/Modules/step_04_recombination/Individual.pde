/*

 Handles the representation and manipulation of individuals.
 It includes:
 - Writting and applying shaders
 
 */

class Individual {

  private Node tree;
  PShader shader;

  String name;

  int nChildNodes;

  Individual() {
    tree = new Node(0);
    tree.randomizeNode(true);
    cleanUp();
    doShader();
  }

  Individual(String _name) {
    name = _name;
    tree = new Node(0);
    tree.randomizeNode(true);
    cleanUp();
    doShader();
  }

  Individual(Node _tree) {
    tree = _tree;
    cleanUp();
    doShader();
  }

  //creates and reads shader file
  void doShader() {
    String [] shaderLines = getShaderTextLines(tree);

    String shaderPath = sketchPath("shaders\\shader" + name + ".glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath, "vertShaderTemplate.glsl");
  }

  void cleanUp() {
    tree.checkNecessaryChildrenNodes();
    identifyNodes();
    tree.removeTooDeep();
    identifyNodes();
  }

  void identifyNodes() {
    nChildNodes = 0;
    tree.identify(this, 0);
  }


  Individual crossover(Individual _partner) {
    Individual child = getCopy();

    //loop to make recombination more aparent, it is not necessary
    for (int i = 0; i < 3; i++) {
      Node partnerNodeCopy = _partner.getRandomNode(true);
      child.replaceRandomNode(partnerNodeCopy);
    }

    return child;
  }

  void replaceRandomNode(Node _newNode) {
    int randomNodeIndex = floor(random(nChildNodes));

    tree.replaceNode(randomNodeIndex, _newNode);
  }

  int getIndex() {
    int toReturn = nChildNodes;
    nChildNodes ++;
    return toReturn;
  }

  Node getRandomNode(boolean _isCopy) {
    int randomNodeIndex = floor(random(nChildNodes));

    Node randomNode = tree.getNode(randomNodeIndex);

    return _isCopy ? randomNode.getCopy() : randomNode;
  }

  Individual getCopy() {
    Node copiedTree = tree.getCopy();

    return new Individual(copiedTree);
  }


  PShader getShader() {
    return shader;
  }
}
