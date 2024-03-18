class FunctionPrimitive{
  
    /*
    types:
    0_ x $ x
    1_ $(x)
    2_ $(x, x)
    */
  
    int type;
    String operator;
    
    FunctionPrimitive(int _type, String _operator){
      type = _type;
      operator = _operator;
    }
    
    int getNumberArgumentsNeeded(){
      if(type == 0 || type == 2) return 2;
      else return 1;
    }
}

FunctionPrimitive[] functionSet;

FunctionPrimitive[] setupFunctionSet(){
  ArrayList<FunctionPrimitive> functionsToReturn = new ArrayList<FunctionPrimitive>();
  
  functionsToReturn.add(new FunctionPrimitive(0, "+"));
  functionsToReturn.add(new FunctionPrimitive(0, "-"));
  functionsToReturn.add(new FunctionPrimitive(0, "*"));
  functionsToReturn.add(new FunctionPrimitive(0, "/"));
  
  functionsToReturn.add(new FunctionPrimitive(1, "sin"));
  functionsToReturn.add(new FunctionPrimitive(1, "cos"));
  functionsToReturn.add(new FunctionPrimitive(1, "tan"));
  
  functionsToReturn.add(new FunctionPrimitive(2, "max"));
  functionsToReturn.add(new FunctionPrimitive(2, "min"));
  functionsToReturn.add(new FunctionPrimitive(2, "noise"));
  functionsToReturn.add(new FunctionPrimitive(2, "mod"));
  functionsToReturn.add(new FunctionPrimitive(2, "pow"));
  functionsToReturn.add(new FunctionPrimitive(2, "audio"));
  functionsToReturn.add(new FunctionPrimitive(2, "bri"));
  
  FunctionPrimitive[] functionsToReturnList = new FunctionPrimitive[functionsToReturn.size()];
  
  for(int i = 0; i < functionsToReturn.size(); i++){
    functionsToReturnList[i] = functionsToReturn.get(i);
  }
  
  return functionsToReturnList;
}

//

class TerminalPrimitive{
  /*
  float       _ 0-1
  x           _ 2
  y           _ 3
  externalVal _ 4
  */
  
  /*
  types:
  0_float
  1_string
  */
  String value;
  
  TerminalPrimitive(String _value){
      value = _value;
  }
}

TerminalPrimitive[] terminalSet;

TerminalPrimitive[] setupTerminalSet(){
  
  ArrayList<TerminalPrimitive> terminalsToReturn = new ArrayList<TerminalPrimitive>();
  
  terminalsToReturn.add(new TerminalPrimitive("x"));
  terminalsToReturn.add(new TerminalPrimitive("y"));
  terminalsToReturn.add(new TerminalPrimitive("externalVal"));
  
  TerminalPrimitive[] terminalsToReturnList = new TerminalPrimitive[terminalsToReturn.size()];
  
  for(int i = 0; i < terminalsToReturn.size(); i++){
    terminalsToReturnList[i] = terminalsToReturn.get(i);
  }
  
  return terminalsToReturnList;
}
