class Node {

  int nMathTypes = operations.length;
  float mathType;

  int nodeIndex;
  int depth;

  Node aNode = null;
  Node bNode = null;

  int nValTypes = 3; //0-x 1-y 2-external
  float aType;  //0-1
  float bType;

  Node(int _depth) {
    depth = _depth;
  }

  Node(boolean _toRandomize) {
    if (_toRandomize) randomizeNode();
  }

  Node(float _mathType, Node _aNode, Node _bNode, float _aType, float _bType) {
    mathType = _mathType;
    aNode = _aNode;
    bNode = _bNode;
    aType = _aType;
    bType = _bType;
  }

  void randomizeNode() {
    mathType = random(1);

    aType = random(1);
    bType = random(1);

    if (random(1) > .5 && depth < maxDepth - 1) {
      aNode = new Node(depth + 1);
      aNode.randomizeNode();
    }
    if (random(1) > .5 && depth < maxDepth - 1) {
      bNode = new Node(depth + 1);
      bNode.randomizeNode();
    }
  }

  void identify(int _parentIndex, Individual _indiv) { //parentIndex refers to individual's nodes[ID]

    nodeIndex = _indiv.getIndex(_parentIndex);

    if (aNode != null) aNode.identify(_parentIndex, _indiv);
    if (bNode != null) bNode.identify(_parentIndex, _indiv);
  }

  void mutate() {
    float toAdd = random(-.1, .1);
    mathType = constrain(mathType + toAdd, 0, 1);

    toAdd = random(-.1, .1);
    aType = constrain(aType + toAdd, 0, 1);
    
    toAdd = random(-.1, .1);
    bType = constrain(bType + toAdd, 0, 1);
  }

  Node getCopy() {
    Node aNodeCopy = aNode == null ? null : aNode.getCopy();
    Node bNodeCopy = bNode == null ? null : bNode.getCopy();

    return new Node(mathType, aNodeCopy, bNodeCopy, aType, bType);
  }

  Node getNode(int _index) {
    if (nodeIndex == _index) return this;

    if (aNode != null) {
      Node potencialNode = aNode.getNode(_index);
      if (potencialNode != null) return potencialNode;
    }

    if (bNode != null) {
      Node potencialNode = bNode.getNode(_index);
      if (potencialNode != null) return potencialNode;
    }

    return null;
  }

  void replaceNode(int _index, Node _newNode) {
    if (aNode != null && aNode.nodeIndex == _index) {
      aNode = _newNode;
      return;
    } else if (bNode != null && bNode.nodeIndex == _index) {
      bNode = _newNode;
      return;
    }

    if (aNode != null) {
      aNode.replaceNode(_index, _newNode);
    }

    if (bNode != null) {
      bNode.replaceNode(_index, _newNode);
    }
  }

  String getFunctionString() {
    String finalString = "";
    Operation operation = operations[getMathType(mathType)];

    if (operation.type != 0) {
      finalString += operations[getMathType(mathType)].operator;
    }

    finalString += "(";

    if (aNode != null) {
      finalString += aNode.getFunctionString();
    } else {
      switch(getValType(aType)) {
      case 0:
        finalString += "x";
        break;
      case 1:
        finalString += "y";
        break;
      case 2:
        finalString += "externalVal";
        break;
      }
    }

    if (operation.type == 0) {
      finalString += operations[getMathType(mathType)].operator;
    } else if (operation.type == 2) {
      finalString += ",";
    } else {
      finalString += ")";
      return finalString;
    }

    if (bNode != null) {
      finalString += bNode.getFunctionString();
    } else {
      switch(getValType(bType)) {
      case 0:
        finalString += "x";
        break;
      case 1:
        finalString += "y";
        break;
      case 2:
        finalString += "externalVal";
        break;
      }
    }

    finalString += ")";
    return finalString;
  }
  
  int getValType(float _type){
    int value = floor(map(_type, 0, 1, 0, nValTypes));
    value = constrain(value, 0, nValTypes - 1); //if _type is 1 value = nValTypes which is out of bounds
    return value;
  }
  
  int getMathType(float _type){
    int value = floor(map(_type, 0, 1, 0, nMathTypes));
    value = constrain(value, 0, nMathTypes - 1);
    return value;
  }
}
