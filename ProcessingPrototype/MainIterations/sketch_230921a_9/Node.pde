class Node {

  int nMathTypes = 12;
  int mathType;

  int nodeIndex;
  int depth;

  Node aNode = null;
  Node bNode = null;

  int aType; //0-x 1-y 2-external
  int bType;

  Node(int _depth) {
    depth = _depth;
  };

  Node(boolean _toRandomize) {
    if (_toRandomize) randomizeNode();
  }

  Node(int _mathType, Node _aNode, Node _bNode, int _aType, int _bType) {
    mathType = _mathType;
    aNode = _aNode;
    bNode = _bNode;
    aType = _aType;
    bType = _bType;
  }

  void randomizeNode() {
    mathType = floor(random(nMathTypes));

    aType = floor(random(3));
    bType = floor(random(3));

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
    else if (random(1) < mutationRate) aNode = null;

    if (random(1) < mutationRate) bNode = new Node(true);
    else if (random(1) < mutationRate) bNode = null;

    if (random(1) < mutationRate) {
      mathType = floor(random(nMathTypes));
    }
  }

  float getValue(float _x, float _y, float _external) {
    float valueA = 0, valueB = 0;
    if (aNode != null) valueA = aNode.getValue(_x, _y, _external);
    else {
      switch(aType) {
      case 0:
        valueA = _x;
        break;
      case 1:
        valueA = _y;
        break;
      case 2:
        valueA = _external;
        break;
      }
    }

    if (bNode != null) valueB = bNode.getValue(_x, _y, _external);
    else {
      switch(aType) {
      case 0:
        valueB = _x;
        break;
      case 1:
        valueB = _y;
        break;
      case 2:
        valueB = _external;
        break;
      }
    }

    float value = doMath(valueA, valueB, mathType);

    return value;
  }

  Node getCopy() {
    Node aNodeCopy = aNode == null ? null : aNode.getCopy();
    Node bNodeCopy = bNode == null ? null : bNode.getCopy();

    return new Node(mathType, aNodeCopy, bNodeCopy, aType, bType);
  }

  float doMath(float a, float b, int _type) {
    float toReturn = 0;

    switch(_type) {
    case 0: //sum GLSL
      toReturn = a + b;
      break;
    case 1: //subtraction GLSL
      toReturn = a - b;
      break;
    case 2: //multiplication GLSL
      toReturn = a * b;
      break;
    case 3: //division GLSL
      if (b == 0) toReturn = 0;
      toReturn = a / b;
      break;
    case 4: //sin GLSL
      toReturn = sin(a);
      break;
    case 5: //cos GLSL
      toReturn = cos(a);
      break;
    case 6: //tan GLSL
      toReturn = tan(a);
      break;
    case 7: //max GLSL
      toReturn = max(a, b);
      break;
    case 8: //min GLSL
      toReturn = min(a, b);
      break;
    case 9: //noise
      toReturn = noise(a, b);
      break;
    case 10: //modulo GLSL
      toReturn = a%b;
      break;
    case 11: //power GLSL
      toReturn = pow(a, b);
      break;
      /*case 12: //magnitude
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
       }*/
    }

    return toReturn;
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
    Operation operation = operations[mathType];

    if (operation.type != 0) {
      finalString += operations[mathType].operator;
    }

    finalString += "(";

    if (aNode != null) {
      finalString += aNode.getFunctionString();
    } else {
      switch(aType) {
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
      finalString += operations[mathType].operator;
    } else if (operation.type == 2) {
      finalString += ",";
    } else {
      finalString += ")";
      return finalString;
    }

    if (bNode != null) {
      finalString += bNode.getFunctionString();
    } else {
      switch(bType) {
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
}
