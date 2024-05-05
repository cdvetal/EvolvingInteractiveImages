class Operation{
  
    /*
    types:
    0_ x $ x
    1_ $(x)
    2_ $(x, x)
    */
  
    int type;
    String operator;
    String explanation;
    boolean defaultToggle = true;
    
    Operation(int _type, String _operator){
      type = _type;
      operator = _operator;
    }
    
    Operation(int _type, String _operator, String _explanation){
      type = _type;
      operator = _operator;
      explanation = _explanation;
    }
    
    Operation(int _type, String _operator, boolean _toggle){
      type = _type;
      operator = _operator;
      defaultToggle = _toggle;
    }
    
    Operation(int _type, String _operator, boolean _toggle, String _explanation){
      type = _type;
      operator = _operator;
      defaultToggle = _toggle;
      explanation = _explanation;
    }
    
    int getNumberArgumentsNeeded(){
      if(type == 0 || type == 2) return 2;
      else return 1;
    }
}

Operation[] setupOperations(){
  ArrayList<Operation> operationsToReturn = new ArrayList<Operation>();
  
  operationsToReturn.add(new Operation(0, "+", true));
  operationsToReturn.add(new Operation(0, "-", true));
  operationsToReturn.add(new Operation(0, "*", true));
  operationsToReturn.add(new Operation(0, "/", true));
  
  operationsToReturn.add(new Operation(1, "sin", true));
  operationsToReturn.add(new Operation(1, "cos", true));
  operationsToReturn.add(new Operation(1, "tan", true));
  operationsToReturn.add(new Operation(1, "var", true, "variables"));
  
  operationsToReturn.add(new Operation(2, "aud", true, "sound"));
  operationsToReturn.add(new Operation(2, "aul", true, "sound - lows"));
  operationsToReturn.add(new Operation(2, "auh", true, "sound - highs"));
  operationsToReturn.add(new Operation(2, "bri", false, "camera"));
  operationsToReturn.add(new Operation(2, "max", true));
  operationsToReturn.add(new Operation(2, "min", true));
  operationsToReturn.add(new Operation(2, "noi", false, "perlin noise"));
  operationsToReturn.add(new Operation(2, "mod", false));
  operationsToReturn.add(new Operation(2, "pow", true));  
  
  Operation[] operationsToReturnList = new Operation[operationsToReturn.size()];
  
  for(int i = 0; i < operationsToReturn.size(); i++){
    operationsToReturnList[i] = operationsToReturn.get(i);
  }
  
  return operationsToReturnList;
}
