class Node {

  int nMathTypes = operations.length;
  float mathType; //0-1

  int nodeIndex;
  int depth;

  Node aNode = null;
  Node bNode = null;

  String[] valTypes = {"x", "y", "externalVal"};
  float aValType;  //0-1  //need to change. node must BE variable, not HAVE variables
  float bValType;

  Node(int _depth) {
    depth = _depth;
  }

  Node(boolean _toRandomize, boolean _tocreateChildren) {
    if (_toRandomize) randomizeNode(_tocreateChildren);
  }

  Node(float _mathType, Node _aNode, Node _bNode, float _aValType, float _bValType) {
    mathType = _mathType;
    aNode = _aNode;
    bNode = _bNode;
    aValType = _aValType;
    bValType = _bValType;
  }

  Node(String _expression) {
    setupNodeFromExpression(_expression);
  }

  void randomizeNode(boolean _tocreateChildren) {
    mathType = random(1);

    aValType = random(1);
    bValType = random(1);

    if (!_tocreateChildren) {
      aNode = null;
      bNode = null;
      return;
    }

    if (random(1) > .5 && depth < maxDepth - 1) {
      aNode = new Node(depth + 1);
      aNode.randomizeNode(true);
    }
    if (random(1) > .5 && depth < maxDepth - 1) {
      bNode = new Node(depth + 1);
      bNode.randomizeNode(true);
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
    aValType = constrain(aValType + toAdd, 0, 1);

    toAdd = random(-.1, .1);
    bValType = constrain(bValType + toAdd, 0, 1);
  }

  Node getCopy() {
    Node aNodeCopy = aNode == null ? null : aNode.getCopy();
    Node bNodeCopy = bNode == null ? null : bNode.getCopy();

    return new Node(mathType, aNodeCopy, bNodeCopy, aValType, bValType);
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
      finalString += getValTypeString(getValType(aValType));
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
      finalString += getValTypeString(getValType(bValType));
    }

    finalString += ")";
    return finalString;
  }
  
  void setupNodeFromExpression(String _expression) {
    
    if (_expression.length() <= 0) println("invalid expression: too short");
    _expression = removeStartAndEndParenthesis(_expression);
    println("\n" + _expression + "_NEW EXPRESSION");
    
    mathType = -1;
    aValType = -1;
    bValType = -1;
    Operation operation = null;
    
    for(int i = 0; i < valTypes.length; i++){
     if(_expression.equals(valTypes[i])){
       aValType = map(i, 0, valTypes.length, 0, 1);
       mathType = random(1);
       bValType = random(1);
       return;
     }
    }
    
    int mainOperatorIndex = getMainSimpleOperatorIndex(_expression);
    //operation is of type 0_ x $ x
    if(mainOperatorIndex >= 0){
      String operatorString = String.valueOf(_expression.charAt(mainOperatorIndex));

      for (int i = 0; i < operations.length; i ++) {
        if (operations[i].operator.equals(operatorString)) {
          operation = operations[i];
          mathType = mathTypeFromOperatorIndex(i);
        }
      }

      String[] expressionHalves = splitStringAtIndex(_expression, mainOperatorIndex);

      setupNodeFromExpressionHalves(expressionHalves);
      return;
    }

    //check for type 1 or 2 - expression must start with "operator("
    for (int i = 0; i < operations.length; i ++) {

      //operation of type 1 or 2 must end in ')'
      if (_expression.charAt(_expression.length()-1) != ')') break;
      if (operations[i].type > 0) {

        String operator = operations[i].operator;
        int operatorLength = operator.length();

        //if start of expression is operator
        if (_expression.length() < operatorLength) continue;
        if (_expression.substring(0, operatorLength).equals(operations[i].operator)) {
          operation = operations[i];
          mathType = mathTypeFromOperatorIndex(i);

          //remove operator and parenthesis(start and end)
          println("operator is: " + operator);
          _expression = _expression.substring(operatorLength + 1, _expression.length() - 1);
          println(_expression + "_ cut expression");
          break;
        }
      }
    }

    if (operation.type == 1) { //operation is of type 1_ $(x)
      println("\nExpression is of type 1");

      for (int i = 0; i < valTypes.length; i++) {
        if (valTypes[i].equals(_expression))
        {
          aValType = map(i, 0, valTypes.length, 0, 1);
          bValType = random(1);
          return;
        }
      }

      aNode = new Node(_expression);
      aValType = random(1);
      bValType = random(1);
      return;
    }

    if (operation.type == 2) { //operation is of type 2_ $(x, x)
      println("\nExpression is of type 2");

      int mainCommaIndex = getMainCommaIndex(_expression);

      String[] expressionHalves = splitStringAtIndex(_expression, mainCommaIndex);
      println(_expression);
      println(expressionHalves);

      setupNodeFromExpressionHalves(expressionHalves);
      return;
    }
    
    println("ERROR: no operation found");
  }

  void setupNodeFromExpressionHalves(String[] _expressionHalves) {
    _expressionHalves[0] = removeStartAndEndParenthesis(_expressionHalves[0]);
    _expressionHalves[1] = removeStartAndEndParenthesis(_expressionHalves[1]);
    
    for (int i = 0; i < valTypes.length; i++) { //left side of expression is a single value
      if (valTypes[i].equals(_expressionHalves[0]))
      {
        aNode = null;
        aValType = map(i, 0, valTypes.length, 0, 1);
        break;
      }
    }

    if (aValType < 0)
    {
      aValType = random(1);
      aNode = new Node(_expressionHalves[0]);
    }

    for (int i = 0; i < valTypes.length; i++) { //right side of expression is a single value
      if (valTypes[i].equals(_expressionHalves[1]))
      {
        bNode = null;
        bValType = map(i, 0, valTypes.length, 0, 1);
        break;
      }
    }

    if (bValType < 0)
    {
      bValType = random(1);
      bNode = new Node(_expressionHalves[1]);
    }
    
  }

  void removeUnusedNodes() {
    int requiredArguments =  operations[getMathType(mathType)].getNumberArgumentsNeeded();

    if (requiredArguments == 0) {
      aNode = null;
      bNode = null;
      return;
    }

    if (requiredArguments == 1) {
      bNode = null;
      return;
    }
  }

  int getValType(float _type) {
    int value = floor(map(_type, 0, 1, 0, valTypes.length));
    value = constrain(value, 0, valTypes.length); //could be wrong
    return value;
  }

  int getMathType(float _type) {
    int value = floor(map(_type, 0, 1, 0, nMathTypes));
    value = constrain(value, 0, nMathTypes - 1);
    return value;
  }

  String getValTypeString(int _type) {
    _type = constrain(_type, 0, valTypes.length-1);
    return valTypes[_type];
  }

  float mathTypeFromOperatorIndex(int _operatorIndex) {
    return map(_operatorIndex, 0, operations.length, 0, 1 -0.001);
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
      if (c == '('){
        openedParenthesis += 1;
        if(openedParenthesis == 1) openedAtIndex = i;
      }
      else if (c == ')'){
        openedParenthesis -= 1;
      }
    }
    
    if(_string.charAt(0) == '(' && _string.charAt(_string.length() - 1) == ')' && openedAtIndex == 0){
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
}
