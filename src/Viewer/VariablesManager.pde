class VariablesManager { //Manages all the external info

  int shaderVariablesArraySize = 10;
  int nVariables;
  //HashMap<String, Integer> variableMap;
  int variableTypes[]; //controls the type of each variable. //-1  manual; 0  mouseX; 1  mouseY; 2  sine wave; 3 perlin

  VariablesManager(int _nVariables) {
    if(_nVariables > shaderVariablesArraySize) _nVariables = shaderVariablesArraySize;
    nVariables = _nVariables;

    variableTypes = new int[nVariables];
    for(int i = 0; i < nVariables; i++){
      variableTypes[i] = 3;
    }
  }

  void switchType (int _variableIndex, int _newType) {
    variableTypes[_variableIndex] = _newType;
  }
  
  float[] getAllVariables () {
    float[] toReturn = new float[nVariables];

    for (int i = 0; i < toReturn.length; i++) {
      toReturn[i] = getVariable(i);
    }

    return toReturn;
  }
  
  float[] getShaderReadyVariables(){
    float[] toReturn = new float[shaderVariablesArraySize];
    
    for (int i = 0; i < nVariables; i++) {
      toReturn[i] = getVariable(i);
    }
    
    return toReturn;
  }

  float getVariable (int _variableIndex) {
    float toReturn = 0;

    switch(variableTypes[_variableIndex]) {
      case(0):
      toReturn = mouseX/float(width);
      break;

      case(1):
      toReturn = mouseY/float(height);
      break;

      case(2):
      toReturn = map(sin((float)millis()/1000), -1, 1, 0, 1);
      break;
      
      case(3):
      toReturn = noise(millis() * 0.0001 + 10000 * _variableIndex);
    }

    return toReturn;
  }
}
