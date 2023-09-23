class Node {

  int nTypes = 12;
  int type;
  
  int depth;
  int breadth;
  
  ArrayList<Node> childrenNodes = new ArrayList<Node>(); //to do...

  Node aNode = null;
  Node bNode = null;

  boolean aCoordinate; //if aNode is null it will be replaced by either X or Y - true is X, false is Y
  boolean bCoordinate;

  boolean aCoordinateOrder; //order of calculations. if true a / b; else b / a
  boolean bCoordinateOrder;

  float finalValue;

  float valueA;
  float valueB;

  Node(Individual _indiv) {
    breadth = _indiv.getNextBreadth(depth);
    //randomizeNode(_indiv);
  }
  
  Node(int _type, Node _aNode, Node _bNode, boolean _aCoordinates, boolean _bCoordinates, boolean _aCoordinateOrder, boolean _bCoordinateOrder){
    type = _type;
    aNode = _aNode;
    bNode = _bNode;
    aCoordinate = _aCoordinates;
    bCoordinate = _bCoordinates;
    aCoordinateOrder = _aCoordinateOrder;
    bCoordinateOrder = _bCoordinateOrder;
  }

  void randomizeNode(Individual _indiv) {
    type = floor(random(nTypes));
    
    int nNodes = floor(random(maxNodeChildren));

    aCoordinateOrder = random(1) > .5;
    bCoordinateOrder = random(1) > .5;

    if (noise(depth, breadth) > .5 && depth < maxDepth - 1) {
      aNode = new Node(_indiv);
    }
    if (noise(depth, breadth) > .5 && depth < maxDepth - 1) {
      bNode = new Node(_indiv);
    }
  }
  
  void identify(int _depth, Individual _indiv){
    breadth = _indiv.getNextBreadth(depth);
    depth = _depth;
    if(aNode != null) aNode.identify(_depth + 1, _indiv);
    if(bNode != null) bNode.identify(_depth + 1, _indiv);
  }
  
  void mutate(Individual _indiv){
    if(aNode != null){
      if(random(1) < mutationRate) aNode = null;
      else aNode.mutate(_indiv);
    }
    else if(random(1) < mutationRate && depth < maxDepth - 1){
      aNode = new Node(_indiv);
    }
    if(bNode != null){
      if(random(1) < mutationRate) aNode = null;
      else bNode.mutate(_indiv);
    }
    else if(random(1) < mutationRate && depth < maxDepth - 1){
      bNode = new Node(_indiv);
    }
    
    if(random(1) < mutationRate){
      type = floor(noise(depth, breadth)*nTypes);
    }
    if(random(1) < mutationRate){
      aCoordinateOrder = !aCoordinateOrder;
    }
    if(random(1) < mutationRate){
      bCoordinateOrder = !bCoordinateOrder;
    }
  }

  float getValue(float _x, float _y) {
    if (aNode != null)valueA = aCoordinateOrder ? aNode.getValue(_x, _y) : aNode.getValue(_y, _x);
    else {
      valueA = aCoordinate? _x : _y;
    }

    if (bNode != null)valueB = bCoordinateOrder ? bNode.getValue(_x, _y) : bNode.getValue(_y, _x);
    else {
      valueB = bCoordinate? _x : _y;
    }

    return doMath(valueA, valueB);
  }
  
  Node getCopy(){
    Node aNodeCopy = aNode == null ? null : aNode.getCopy();
    Node bNodeCopy = bNode == null ? null : bNode.getCopy();
    return new Node(type, aNodeCopy, bNodeCopy, aCoordinate, bCoordinate, aCoordinateOrder, bCoordinateOrder);
  }

  float doMath(float a, float b) {
    float toReturn = 0;

    switch(type) {
    case 0: //sum
      toReturn = a + b;
      break;
    case 1: //subtraction
      toReturn = a - b;
      break;
    case 2: //multiplication
      toReturn = a * b;
      break;
    case 3: //division
      if (b == 0) toReturn = 0;
      toReturn = a / b;
      break;
    case 4: //sin
      toReturn = sin(a);
      break;
    case 5: //cos
      toReturn = cos(a);
      break;
    case 6: //tan
      toReturn = tan(a);
      break;
    case 7: //max
      toReturn = max(a, b);
      break;
    case 8: //min
      toReturn = min(a, b);
      break;
    case 9: //noise
      toReturn = noise(a, b);
      break;
    case 10: //modulo
      toReturn = a%b;
      break;
    case 11: //magnitude
      {
        PVector vector = new PVector(a, b);
        toReturn = vector.mag();
        break;
      }
    case 12: //maxmagnitude - magnitude
      {
        PVector unitVector = new PVector(1, 1);
        PVector vector = new PVector(a, b);
        toReturn = unitVector.mag() - vector.mag();
        break;
      }
    }

    return toReturn;
  }
}
