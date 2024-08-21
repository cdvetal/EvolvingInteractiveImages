/*

 Handles the representation and manipulation of individuals.
 It includes:
 - Writting and applying shaders
 - Mutating Individual
 
 */

class Individual {

  private Node tree;
  PShader shader;

  int nChildNodes = 0;

  Individual() {
    tree = new Node(0);
    tree.randomizeNode(true);
    doShader();
    cleanUp();
  }

  //creates and reads shader file
  void doShader() {
    String [] shaderLines = getShaderTextLines(tree);

    String shaderPath = sketchPath("shaders\\shader.glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath, "vertShaderTemplate.glsl");
  }

  void cleanUp() {
    tree.checkNecessaryChildrenNodes();
    identifyNodes();
    tree.removeTooDeep();
    identifyNodes();
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
    
    doShader();
  }
  
  void identifyNodes() {
    nChildNodes = 0;
    tree.identify(this, 0);
  }

  int getIndex() {
    int toReturn = nChildNodes;
    nChildNodes ++;
    return toReturn;
  }

  void replaceRandomNode(Node _newNode) {
    int randomNodeIndex = floor(random(nChildNodes));

    tree.replaceNode(randomNodeIndex, _newNode);
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


  PShader getShader() {
    return shader;
  }
}
