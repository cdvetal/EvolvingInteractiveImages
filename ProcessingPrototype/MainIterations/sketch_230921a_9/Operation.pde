class Operation{
  
    /*
    types:
    0_ x $ x
    1_ $(x)
    2_ $(x, x)
    */
  
    int type;
    String operator;
    
    Operation(int _type, String _operator){
      type = _type;
      operator = _operator;
    }
}

Operation[] setupOperations(){
  ArrayList<Operation> operationsToReturn = new ArrayList<Operation>();
  
  operationsToReturn.add(new Operation(0, "+"));
  operationsToReturn.add(new Operation(0, "-"));
  operationsToReturn.add(new Operation(0, "*"));
  operationsToReturn.add(new Operation(0, "/"));
  
  operationsToReturn.add(new Operation(1, "sin"));
  operationsToReturn.add(new Operation(1, "cos"));
  operationsToReturn.add(new Operation(1, "tan"));
  
  operationsToReturn.add(new Operation(2, "max"));
  operationsToReturn.add(new Operation(2, "min"));
  operationsToReturn.add(new Operation(2, "noise1"));
  operationsToReturn.add(new Operation(2, "mod"));
  operationsToReturn.add(new Operation(2, "pow"));
  
  Operation[] operationsToReturnList = new Operation[operationsToReturn.size()];
  
  for(int i = 0; i < operationsToReturn.size(); i++){
    operationsToReturnList[i] = operationsToReturn.get(i);
  }
  
  return operationsToReturnList;
}
