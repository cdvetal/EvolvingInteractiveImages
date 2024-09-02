/*

Operations (or Functions) that make up the function set.

*/

class Operation{
  
  
    int nArguments;
    String operator;
    String explanation;
    boolean defaultToggle = true;
    
    Operation(int _nArguments, String _operator){
      nArguments = _nArguments;
      operator = _operator;
    }
    
    Operation(int _nArguments, String _operator, String _explanation){
      nArguments = _nArguments;
      operator = _operator;
      explanation = _explanation;
    }
    
    Operation(int _nArguments, String _operator, boolean _toggle){
      nArguments = _nArguments;
      operator = _operator;
      defaultToggle = _toggle;
    }
    
    Operation(int _nArguments, String _operator, boolean _toggle, String _explanation){
      nArguments = _nArguments;
      operator = _operator;
      defaultToggle = _toggle;
      explanation = _explanation;
    }
    
    int getNumberArgumentsNeeded(){
      return nArguments;
    }
}

Operation[] setupOperations(){
  ArrayList<Operation> operationsToReturn = new ArrayList<Operation>();
  
  /* DEPRECATED
  operationsToReturn.add(new Operation(0, "+", true));
  operationsToReturn.add(new Operation(0, "-", true));
  operationsToReturn.add(new Operation(0, "*", true));
  operationsToReturn.add(new Operation(0, "/", true));
  */
  
  operationsToReturn.add(new Operation(2, "add", true, "Addition"));
  operationsToReturn.add(new Operation(2, "sub", true, "Subtraction"));
  operationsToReturn.add(new Operation(2, "mul", true, "Multiplication"));
  operationsToReturn.add(new Operation(2, "div", true, "Division"));
  
  operationsToReturn.add(new Operation(1, "sin", true, "Sine"));
  operationsToReturn.add(new Operation(1, "cos", true, "Cosine"));
  operationsToReturn.add(new Operation(1, "tan", true, "Tangent"));
  operationsToReturn.add(new Operation(1, "var", true, "Variables"));

  
  operationsToReturn.add(new Operation(2, "xor", true, "XOR"));
  operationsToReturn.add(new Operation(3, "iff", true, "If"));
  operationsToReturn.add(new Operation(1, "sqr", true, "Square root"));
  
  operationsToReturn.add(new Operation(2, "aud", true, "Sound"));
  operationsToReturn.add(new Operation(2, "aul", false, "Sound - lows"));
  operationsToReturn.add(new Operation(2, "auh", false, "Sound - highs"));
  operationsToReturn.add(new Operation(2, "bri", false, "Camera"));
  operationsToReturn.add(new Operation(2, "max", true, "Maximum"));
  operationsToReturn.add(new Operation(2, "min", true, "Minimum"));
  operationsToReturn.add(new Operation(2, "noi", true, "Perlin noise"));
  operationsToReturn.add(new Operation(2, "mod", true, "Modulo"));
  operationsToReturn.add(new Operation(2, "pow", true, "Power"));  
  
  Operation[] operationsToReturnList = new Operation[operationsToReturn.size()];
  
  for(int i = 0; i < operationsToReturn.size(); i++){
    operationsToReturnList[i] = operationsToReturn.get(i);
  }
  
  return operationsToReturnList;
}
