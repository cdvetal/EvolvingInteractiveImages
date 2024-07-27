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
    if (random(1) > .45 && depth < maxDepth - 1 && _tocreateChildren) {
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
        //if operation of type x + y
        if (operation.type == 0) finalString += operation.operator;
        else finalString += ",";
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
    if (depth == maxDepth) {
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

  int getMathType(float _type) {
    int value = floor(map(_type, 0, 1, 0, enabledOperations.length));
    value = constrain(value, 0, enabledOperations.length - 1);
    return value;
  }

  float mathTypeFromOperatorIndex(int _operatorIndex) {
    return map(_operatorIndex, 0, enabledOperations.length, 0, 1 -0.001);
  }

  void setupNodeFromExpression(String[] _expressions) {

    int firstParenthesisPos = _expressions[0].indexOf('(');
    int lastParenthesisPos = _expressions[0].lastIndexOf(')');

    if (firstParenthesisPos < 0 || lastParenthesisPos < 0) { //means it's scalar

      return;
    }

    //substring(0,10)
    String functionString = _expressions[0].substring(0, firstParenthesisPos);

    mathType = getMathTypeValueFromString(functionString);



    String inParenthesis = _expressions[0].substring(firstParenthesisPos + 1, lastParenthesisPos);
  }

  float getMathTypeValueFromString(String _functionString) {
    for (int i = 0; i < operations.length; i ++) {
      if (operations[i].operator == _functionString) return (1 / operations.length * i);
    }
    return 0;
  }

  String removeStartAndEndParenthesis(String _string) {
    if (_string.length() <= 0) {
      println("string at removeStartAndEndParenthesis is too short " + _string);
      return _string;
    }
    if (!_string.contains("(")) return _string;

    int openedParenthesis = 0;
    int openedAtIndex = -1; //to check if first parenthesis closes before finish
    for (int i = 0; i < _string.length(); i++) {
      char c = _string.charAt(i);
      if (c == '(') {
        openedParenthesis += 1;
        if (openedParenthesis == 1) openedAtIndex = i;
      } else if (c == ')') {
        openedParenthesis -= 1;
      }
    }

    if (_string.charAt(0) == '(' && _string.charAt(_string.length() - 1) == ')' && openedAtIndex == 0) {
      _string = _string.substring(1, _string.length() - 1);
    }

    return _string;
  }

  int getMainCommaIndex(String _string) { // (((,),))','(,)(,) returns highlighted comma index
    int openedParenthesis = 0;

    if (!_string.contains(",")) {
      println("No commas found at getMainCommaIndex(" + _string + ")");
      return 0;
    }

    for (int i = 0; i < _string.length(); i++) {
      char c = _string.charAt(i);
      if (c == '(') openedParenthesis += 1;
      else if (c == ')') openedParenthesis -= 1;
      else if (c == ',' && openedParenthesis == 0) return i;

      if (openedParenthesis < 0) {
        println("Negative openedParenthesis at getMainCommaIndex(" + _string + ")");
        return 0;
      }
    }

    println("No acceptable comma at getMainCommaIndex(" + _string + ")");
    return -1;
  }

  int getMainSimpleOperatorIndex(String _string) { // (((,),))'*'(,)(,) returns highlighted operator index
    int openedParenthesis = 0;

    String allSimpleOperators = "";

    for (Operation o : operations) {
      if (o.type != 0) continue;
      allSimpleOperators += o.operator;
    }

    for (int i = 0; i < _string.length(); i++) {
      char c = _string.charAt(i);
      if (c == '(') openedParenthesis += 1;
      else if (c == ')') openedParenthesis -= 1;
      else if (allSimpleOperators.contains(String.valueOf(c)) && openedParenthesis == 0) return i;

      if (openedParenthesis < 0) {
        println("Negative openedParenthesis at getMainSimpleOperatorIndex(" + _string + ")");
        return 0;
      }
    }

    println("No acceptable simple operator at getMainSimpleOperatorIndex(" + _string + ")");
    return -1;
  }

  boolean isTerminal() {
    return (childrenNodes.length == 0);
  }

  PVector getVisLocation() {
    return new PVector(visX, depth);
  }

  float[] getRandomScalar() {
    float[] toReturn = new float[3];
    for (int i = 0; i < 3; i++) {
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
