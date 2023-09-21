class Node {

  int nTypes = 9;
  int type;
  int depth;

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

  Node(int _depth) {
    depth = _depth;
    randomizeNode();
  }

  void randomizeNode() {
    type = floor(random(nTypes));
    
    aCoordinateOrder = random(1) > .5;
    bCoordinateOrder = random(1) > .5;
    
    if (random(1) > .48 && depth < maxDepth) {
      aNode = new Node(depth + 1);
    }
    if (random(1) > .48 && depth < maxDepth) {
      bNode = new Node(depth + 1);
    }
  }

  float getValue(float _x, float _y) {
    if (aNode != null)valueA = aCoordinateOrder ? aNode.getValue(_x, _y) : aNode.getValue(_y, _x);
    else {
      if (aCoordinate) valueA = _x;
      else valueA = _y;
    }

    if (bNode != null)valueB = bCoordinateOrder ? bNode.getValue(_x, _y) : bNode.getValue(_y, _x);
    else {
      if (bCoordinate) valueB = _y;
      else valueB = _y;
    }

    return doMath(valueA, valueB);
  }

  float doMath(float a, float b) {
    float toReturn = -1000;

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
      toReturn = max(a,b);
    break;
    case 8: //min
      toReturn = min(a,b);
    break;
    case 9: //noise
      toReturn = noise(a,b);
    break;
    case 10: //modulo
      toReturn = a%b;
    break;
    }

    return toReturn;
  }
}
