class Node{

}

class Function extends Node{
  
  int nFunctionTypes; //number of different function primitives
  float functionType; //0-1 ; decides this function

}

class Terminal extends Node{
  
  String[] scalar;
  
  Terminal(){
    scalar = new String[3];
    
    for(int i = 0; i < scalar.length; i++){ //populate scalar
      float terminalRNG = random(1);
      int scalarType = floor(terminalRNG * (terminalSet.length + 1));
      
      if(scalarType == 0){ //scalar is float
      
        float scalarRNG = random(1);
        scalar[i] = Float.toString(scalarRNG);
        
      } else { //scalar is variable
        int terminalIndex = scalarType - 1;
        scalar[i] = terminalSet[terminalIndex].value;
      }
    }
  }
  
  void printSomething(){
   println("haha"); 
  }
  
}
