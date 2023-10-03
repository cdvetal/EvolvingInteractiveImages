class Node {

  int nMathTypes = 12;
  int mathType;

  int nodeIndex;
  int depth;

  Node aNode = null;
  Node bNode = null;

  boolean isAffected; //if a node is changed based on external information
  int affectionMathType;

  boolean aCoordinate; //if aNode is null it will be replaced by either X or Y - true is X, false is Y
  boolean bCoordinate;
  
  Node(int _depth){
    depth = _depth;
  };
  
  Node(boolean _toRandomize){
    if(_toRandomize) randomizeNode();
  }

  Node(int _mathType, boolean _isAffected, int _affectionMathType, Node _aNode, Node _bNode, boolean _aCoordinates, boolean _bCoordinates) {
    mathType = _mathType;
    isAffected = _isAffected;
    affectionMathType = _affectionMathType;
    aNode = _aNode;
    bNode = _bNode;
    aCoordinate = _aCoordinates;
    bCoordinate = _bCoordinates;
  }

  void randomizeNode() {
    mathType = floor(random(nMathTypes));

    isAffected = random(1) > .5;
    affectionMathType = floor(random(nMathTypes));

    aCoordinate = random(1) > .5;
    bCoordinate = random(1) > .5;

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

  void mutate() { //to improve
    if (random(1) < mutationRate) aNode = new Node(true);
    else if(random(1) < mutationRate) aNode = null;
    
    if (random(1) < mutationRate) bNode = new Node(true);
    else if(random(1) < mutationRate) bNode = null;
    
    if (random(1) < mutationRate) {
      mathType = floor(random(nMathTypes));
    }
    if (random(1) < mutationRate) {
      affectionMathType = floor(random(nMathTypes));
    }
  }

  float getValue(float _x, float _y, float _external) {
    float valueA, valueB;
    if (aNode != null)valueA = aNode.getValue(_x, _y, _external);
    else {
      valueA = aCoordinate? _x : _y;
    }

    if (bNode != null)valueB = bNode.getValue(_x, _y, _external);
    else {
      valueB = bCoordinate? _x : _y;
    }

    float value = doMath(valueA, valueB, mathType);
    
    if (isAffected) return doMath(value, _external, affectionMathType);
    else return value;
  }

  Node getCopy() {
    Node aNodeCopy = aNode == null ? null : aNode.getCopy();
    Node bNodeCopy = bNode == null ? null : bNode.getCopy();
    
    return new Node(mathType, isAffected, affectionMathType, aNodeCopy, bNodeCopy, aCoordinate, bCoordinate);
  }

  float doMath(float a, float b, int _type) {
    float toReturn = 0;

    switch(_type) {
    case 0: //sum
      toReturn = a + b;
      break;
    case 1: //subtraction
      toReturn = a - b;
      break;
    case 2: //multiplication
      toReturn = a * b;
      break;
    case 3: //division
      if (b == 0) toReturn = 0;
      toReturn = a / b;
      break;
    case 4: //sin
      toReturn = sin(a);
      break;
    case 5: //cos
      toReturn = cos(a);
      break;
    case 6: //tan
      toReturn = tan(a);
      break;
    case 7: //max
      toReturn = max(a, b);
      break;
    case 8: //min
      toReturn = min(a, b);
      break;
    case 9: //noise
      toReturn = noise(a, b);
      break;
    case 10: //modulo
      toReturn = a%b;
      break;
    case 11:
      toReturn = pow(a, b);
      break;
    case 12: //magnitude
      {
        PVector vector = new PVector(a, b);
        toReturn = vector.mag();
        break;
      }
    case 13: //maxmagnitude - magnitude
      {
        PVector unitVector = new PVector(1, 1);
        PVector vector = new PVector(a, b);
        toReturn = unitVector.mag() - vector.mag();
        break;
      }
    }

    return toReturn;
  }
  
  Node getNode(int _index){
    if(nodeIndex == _index) return this;
    
    if(aNode != null){
     Node potencialNode = aNode.getNode(_index);
     if(potencialNode != null) return potencialNode;
    }
    
    if(bNode != null){
     Node potencialNode = bNode.getNode(_index);
     if(potencialNode != null) return potencialNode;
    }
    
    return null;
  }
  
  void replaceNode(int _index, Node _newNode){
    if(aNode != null && aNode.nodeIndex == _index){
      aNode = _newNode;
      return;
    }
    else if(bNode != null && bNode.nodeIndex == _index){
      bNode = _newNode;
      return;
    }
    
    if(aNode != null){
      aNode.replaceNode(_index, _newNode);
    }
    
    if(bNode != null){
      bNode.replaceNode(_index, _newNode);
    }
  }
}
