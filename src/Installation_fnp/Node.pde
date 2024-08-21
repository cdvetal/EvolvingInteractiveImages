/*

 Handles the nodes that make up a Genetic Programming Tree.
 Nodes can be of a function or terminal.
 Nodes can have children.
 
 */


class Node {

  float mathType; //0-1

  int nodeIndex;
  int depth;
  int breadth;

  int visX; //location of node in tree visualization horizontally. vertical is depth

  Node[] childrenNodes;

  String[] terminalSet = {"x", "y"};

  float[] scalar = new float[3]; //scalar terminal

  Node() {
    randomizeNode(false);
  }

  Node(int _depth) {
    depth = _depth;
  }

  Node(boolean _toRandomize, boolean _tocreateChildren) {
    if (_toRandomize) randomizeNode(_tocreateChildren);
  }

  Node(float _mathType, Node[] _childrenNodes, float [] _scalar, int _nodeIndex, int _depth, int _breadth) {
    mathType = _mathType;
    childrenNodes = _childrenNodes;
    scalar = _scalar;
    nodeIndex = _nodeIndex;
    depth = _depth;
    breadth = _breadth;
  }

  /*
  //under maintnance
   Node(String _expression) {
   setupNodeFromExpression(_expression);
   }*/

  void randomizeNode(boolean _tocreateChildren) {
    mathType = random(1);

    //decide if node will have children or not
    if (random(1) > .3 && depth < maxTreeDepth - 1 && _tocreateChildren) {
      mathType = random(1);
    } else {
      mathType = -1;
      childrenNodes = new Node[0];
      scalar = getRandomScalar();
      return;
    }

    int requiredArguments =  getOperation().getNumberArgumentsNeeded();

    childrenNodes = new Node[requiredArguments];

    for (int i = 0; i < requiredArguments; i ++) {
      childrenNodes[i] = new Node(depth + 1);
      childrenNodes[i].randomizeNode(true);
    }
  }

  int identify(Individual _indiv, int _depth) {
    depth = _depth;
    visX = 0;

    nodeIndex = _indiv.getIndex();

    breadth = _indiv.getBreadth(depth);
    int childDepth = _depth + 1;

    if (childrenNodes.length > 0) {
      _indiv.addOperation(getOperator());
    } else {
      visX = breadth;
      _indiv.addBreadth();
    }

    for (int i = 0; i < childrenNodes.length; i++) {
      if (i == 0) visX = childrenNodes[i].identify(_indiv, childDepth);
      else childrenNodes[i].identify(_indiv, childDepth);
    }

    return visX;
  }

  void mutate() {
    float toAdd = random(-.1, .1);

    if (isTerminal()) {
      for (int i = 0; i < scalar.length; i++) {
        if (random(1) > mutationRate) continue;
        toAdd = random(-.1, .1);
        scalar[i] = constrain(scalar[i] + toAdd, 0, 1);
      }
    } else {
      mathType = constrain(mathType + toAdd, 0, 1);

      checkNecessaryChildrenNodes();
    }
  }

  Node getCopy() {
    Node[] childrenNodesCopy = new Node[childrenNodes.length];

    for (int i = 0; i < childrenNodes.length; i++) {
      childrenNodesCopy[i] = childrenNodes[i].getCopy();
    }

    return new Node(mathType, childrenNodesCopy, scalar.clone(), nodeIndex, depth, breadth);
  }

  Node getNode(int _index) {
    if (nodeIndex == _index) return this;

    for (int i = 0; i < childrenNodes.length; i++) {
      Node potentialNode = childrenNodes[i].getNode(_index);
      if (potentialNode != null) return potentialNode;
    }

    return null;
  }

  //gets node based on depth and visX
  Node getNodeVis(PVector _visLocation) {
    if (depth > _visLocation.y || visX > _visLocation.x) return null;

    if (depth == int(_visLocation.y) && visX == int(_visLocation.x)) return this;

    for (int i = 0; i < childrenNodes.length; i ++) {
      Node potentialNode = childrenNodes[i].getNodeVis(_visLocation);
      if (potentialNode != null) return potentialNode;
    }

    return null;
  }

  boolean replaceNode(int _index, Node _newNode) {
    for (int i = 0; i < childrenNodes.length; i ++) {
      if (childrenNodes[i].nodeIndex == _index) {
        childrenNodes[i] = _newNode;
        return true;
      }
    }

    for (int i = 0; i < childrenNodes.length; i ++) {
      if (childrenNodes[i].replaceNode(_index, _newNode)) return true;
    }

    return false;
  }

  //function strings for R,G,B
  //scalar index is related to selected expression string (0-R, 1-G, 2-B);
  String getFunctionString(int _scalarIndex) {
    String finalString = "";

    if (childrenNodes.length < 1) {
      finalString += getScalarValueString(_scalarIndex, false);
      return finalString;
    }

    Operation operation = getOperation();

    //if operation if of type opt(xxxxxx)
    if (operation.type != 0) {
      finalString += enabledOperations[getMathType(mathType)].operator;
    }

    finalString += "(";

    for (int i = 0; i < childrenNodes.length; i ++) {
      finalString += childrenNodes[i].getFunctionString(_scalarIndex);

      if (i < childrenNodes.length - 1) {
        finalString += ",";
      }
    }

    finalString += ")";
    return finalString;
  }

  //function string for saving runs
  //scalar is sca()
  String getFunctionString() {
    String finalString = "";

    //adds scalar as sca(#,#,#)
    if (childrenNodes.length < 1) {
      finalString += "sca(";
      for (int i = 0; i < scalar.length; i++) {
        finalString += getScalarValueString(i, false);

        if (i < scalar.length -1) {
          finalString += ",";
        }
      }
      finalString += ")";

      return finalString;
    }

    Operation operation = getOperation();

    //if operation if of type opt(xxxxxx)
    if (operation.type != 0) {
      finalString += enabledOperations[getMathType(mathType)].operator;
    }

    finalString += "(";

    for (int i = 0; i < childrenNodes.length; i ++) {
      finalString += childrenNodes[i].getFunctionString();

      if (i < childrenNodes.length - 1) {
        finalString += ",";
      }
    }

    finalString += ")";
    return finalString;
  }


  //get 3 expressions (R, G and B)
  String[] getExpressions() {
    String[] expressions = new String[3];

    for (int i = 0; i < expressions.length; i++) {
      expressions[i] = getFunctionString(i);
    }

    return expressions;
  }

  //for tree visualization
  String getNodeText() {
    String toReturn = "";

    if (childrenNodes.length < 1) {
      toReturn += "(";
      for (int i = 0; i < scalar.length; i++) {
        toReturn += getScalarValueString(i, true);
        if (i < scalar.length - 1) toReturn += ", ";
      }
      toReturn += ")";
    } else {
      toReturn += getOperator();
    }
    return toReturn;
  }

  //number of necessary children depends on function
  void checkNecessaryChildrenNodes() {
    int requiredArguments =  enabledOperations[getMathType(mathType)].getNumberArgumentsNeeded();

    if (requiredArguments == childrenNodes.length) return;

    if (requiredArguments < childrenNodes.length) {
      Node[] correctChildrenNodes = new Node[requiredArguments];
      for (int i = 0; i < requiredArguments; i ++) {
        correctChildrenNodes[i] = childrenNodes[i].getCopy();
      }
      childrenNodes = correctChildrenNodes;
      return;
    }

    if (requiredArguments > childrenNodes.length) {
      Node[] correctChildrenNodes = new Node[requiredArguments];

      for (int i = 0; i < childrenNodes.length; i ++) {
        correctChildrenNodes[i] = childrenNodes[i].getCopy();
      }

      for (int i = childrenNodes.length; i < requiredArguments; i++) {
        correctChildrenNodes[i] = new Node();
      }
      childrenNodes = correctChildrenNodes;
    }
  }

  void removeTooDeep() {
    if (depth == maxTreeDepth) {
      childrenNodes = new Node[0];
      mathType = -1;
    } else {
      for (int i = 0; i < childrenNodes.length; i++) {
        childrenNodes[i].removeTooDeep();
      }
    }
  }

  //retrieves string from normalized scalar values, from terminal set or value 0-1
  String getScalarValueString(int _scalarIndex, boolean _cropped) {
    float scalarValue = scalar[_scalarIndex];

    int nOptions = terminalSet.length + 1;

    float converter = scalarValue * nOptions;

    //0 - l | is from terminal set
    if (converter <= terminalSet.length) {
      int terminalSetIndex =  constrain(floor(converter), 0, terminalSet.length -1);
      return terminalSet[terminalSetIndex];
    }

    //l - l+1 | is float
    float val = converter - terminalSet.length;
    if (_cropped) {
      return nf(val, 0, 2);
    } else {
      return String.valueOf(val);
    }
  }

  float getScalarValueFromString(String _value) {
    _value = _value.trim();

    int nOptions = terminalSet.length + 1;

    for (int i = 0; i < terminalSet.length; i++) {
      if (terminalSet[i].equals(_value)) {
        float value = ((float)i/nOptions);
        return value;
      }
    }

    float parsedValue = Float.parseFloat(_value);

    return (parsedValue + terminalSet.length) / nOptions * 1.0;
  }

  int getMathType(float _type) {
    int value = floor(map(_type, 0, 1, 0, enabledOperations.length));
    value = constrain(value, 0, enabledOperations.length - 1);
    return value;
  }

  float mathTypeFromOperatorIndex(int _operatorIndex) {
    return map(_operatorIndex, 0, enabledOperations.length, 0, 1 -0.001);
  }

  boolean isTerminal() {
    return (childrenNodes.length == 0);
  }

  PVector getVisLocation() {
    return new PVector(visX, depth);
  }

  float[] getRandomScalar() {
    float[] toReturn = new float[scalar.length];
    for (int i = 0; i < scalar.length; i++) {
      toReturn[i] = random(1);
    }
    return toReturn;
  }

  Operation getOperation() {
    return enabledOperations[getMathType(mathType)];
  }

  String getOperator() {
    return getOperation().operator;
  }
}
