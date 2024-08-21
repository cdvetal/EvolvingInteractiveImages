/*

Operations (or Functions) that make up the function set.

*/

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
    
    int getNumberArgumentsNeeded(){
      if(type == 0 || type == 2) return 2;
      else return 1;
    }
}

Operation[] setupOperations(){
  ArrayList<Operation> operationsToReturn = new ArrayList<Operation>();
  
  operationsToReturn.add(new Operation(2, "add"));
  operationsToReturn.add(new Operation(2, "sub"));
  operationsToReturn.add(new Operation(2, "mul"));
  operationsToReturn.add(new Operation(2, "div"));
  
  operationsToReturn.add(new Operation(1, "sin"));
  operationsToReturn.add(new Operation(1, "cos"));
  operationsToReturn.add(new Operation(1, "tan"));
  
  operationsToReturn.add(new Operation(2, "max"));
  operationsToReturn.add(new Operation(2, "min"));
  operationsToReturn.add(new Operation(2, "pow"));  
  
  //interactive functions - added twice for more likelihood of being used
  operationsToReturn.add(new Operation(2, "aud"));
  operationsToReturn.add(new Operation(2, "bri"));
  operationsToReturn.add(new Operation(2, "aud"));
  operationsToReturn.add(new Operation(2, "bri"));
  
  Operation[] operationsToReturnList = new Operation[operationsToReturn.size()];
  
  for(int i = 0; i < operationsToReturn.size(); i++){
    operationsToReturnList[i] = operationsToReturn.get(i);
  }
  
  return operationsToReturnList;
}
