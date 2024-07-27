/*

Handles the nodes that make up a Genetic Programming Tree.
Nodes can be of a function or terminal.
Nodes can have children.

*/


class Node {

  float mathType; //0-1

  int depth;

  Node[] childrenNodes;

  String[] terminalSet = {"x", "y"};

  float[] scalar = new float[3]; //scalar terminal

  Node(int _depth) {
    depth = _depth;
  }

  void randomizeNode(boolean _tocreateChildren) {
    mathType = random(1);

    //decide if node will have children or not
    if (random(1) > 0.3 && depth < maxDepth - 1 && _tocreateChildren) {
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

  boolean isTerminal() {
    return (childrenNodes.length == 0);
  }
  
  
  Operation getOperation() {
    return enabledOperations[getMathType(mathType)];
  }

  float[] getRandomScalar() {
    float[] toReturn = new float[3];
    for (int i = 0; i < 3; i++) {
      toReturn[i] = random(1);
    }
    return toReturn;
  }
}
