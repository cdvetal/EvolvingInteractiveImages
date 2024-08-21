Individual getRecombination(Individual _parentA, Individual _parentB, String _name){
  Individual child = _parentA.crossover(_parentB);
  child.name = _name;
  child.cleanUp();
  child.doShader();
  return child;
}
