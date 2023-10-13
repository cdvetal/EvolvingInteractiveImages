class Node {

  int nTypes = 12;
  int type;
  
  int depth;
  int breadth;

  Node parentNode;

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
    randomizeNode(_indiv);
  }

  void randomizeNode(Individual _indiv) {
    type = floor(noise(depth, breadth)*nTypes);

    aCoordinateOrder = random(1) > .5;
    bCoordinateOrder = random(1) > .5;

    if (noise(depth, breadth) > .46 && depth < maxDepth - 1) {
      aNode = new Node(_indiv);
    }
    if (noise(depth, breadth) > .46 && depth < maxDepth - 1) {
      bNode = new Node(_indiv);
    }
  }
  
  void identify(int _depth, Individual _indiv){
    breadth = _indiv.getNextBreadth(depth);
    depth = _depth;
    if(aNode != null) aNode.identify(_depth + 1, _indiv);
    if(bNode != null) bNode.identify(_depth + 1, _indiv);
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
