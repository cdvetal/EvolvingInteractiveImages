class Node {

  int nMathTypes = 12;
  int mathType;

  int depth;
  int breadth;

  int nSlotTypes = 5; //0-null 1-x 2-y 3-float 4-node
  int[] slotTypes = new int[maxNodeSlots];
  int[] slotMathTypes = new int[maxNodeSlots];
  ArrayList<Float> floatValues = new ArrayList<Float>();
  ArrayList<Node> nodeChildren = new ArrayList<Node>(); //to do...

  Node() {
  }

  Node(int[] _slotTypes, int[] _slotMathTypes, ArrayList<Float> _floatValues, ArrayList<Node> _nodeChildren) {
    slotTypes = _slotTypes;
    slotMathTypes = _slotMathTypes;
    floatValues = _floatValues;
    nodeChildren =_nodeChildren;
  }

  void randomizeNode() {
    for (int i = 0; i < slotMathTypes.length; i ++) {
      slotMathTypes[i] = floor(random(nMathTypes));
    }

    for (int i = 0; i < slotTypes.length; i ++) {
      slotTypes[i] = floor(random(nSlotTypes));

      if (slotTypes[i] == 3) floatValues.add(random(1));

      if (slotTypes[i] == 4) {
        Node newNode = new Node();
        newNode.randomizeNode();
        nodeChildren.add(newNode);
      }
    }
  }

  void identify(int _depth, Individual _indiv) {
    breadth = _indiv.getNextBreadth(depth);
    depth = _depth;

    for (int i = 0; i < nodeChildren.size(); i++) {
      nodeChildren.get(i).identify(_depth + 1, _indiv);
    }
  }


  void mutate() {
    for (int i = 0; i < slotTypes.length; i ++) {
      if (random(1) > mutationRate) continue;

      int newSlotType = floor(random(nSlotTypes));
      if (newSlotType == slotTypes[i]) continue;

      int oldSlotType = slotTypes[i];

      if (oldSlotType == 3) floatValues.remove(floor(random(floatValues.size() - 1)));
      //else if (oldSlotType == 4) nodeChildren.remove(floor(random(nodeChildren.size() - 1)));

      if (newSlotType == 3) floatValues.add(random(1));
      else if (oldSlotType == 4) {
        Node newNode = new Node();
        newNode.randomizeNode();
        nodeChildren.add(newNode);
      }
      
      slotTypes[i] = newSlotType;
    }
    
    if(random(1) < mutationRate){
      int indexA = floor(random(slotTypes.length));
      int indexB = floor(random(slotTypes.length));
      
      int val = slotTypes[indexA];
      
      slotTypes[indexA] = slotTypes[indexB];
      slotTypes[indexB] = val;
    }
    if(random(1) < mutationRate && floatValues.size() > 1){
      Collections.shuffle(floatValues);
    }
    if(random(1) < mutationRate && nodeChildren.size() > 1){
      Collections.shuffle(nodeChildren);
    }
  }

  float getValue(float _x, float _y) {
    float[] values = new float[maxNodeSlots];

    int floatValueIndex = 0;
    int nodeValueIndex = 0;

    float toReturn = -10000;

    for (int i = 0; i < slotTypes.length; i++) {
      switch(slotTypes[i]) {
      case 1:
        values[i] = _x;
        break;
      case 2:
        values[i] = _y;
        break;
      case 3:
        {
          values[i] = floatValues.get(floatValueIndex);
          floatValueIndex ++;
          break;
        }
      case 4:
        {
          if(nodeValueIndex >= nodeChildren.size())continue; //temporary fix
          values[i] = nodeChildren.get(nodeValueIndex).getValue(_x, _y);
          nodeValueIndex ++;
          break;
        }
      }
      if (slotTypes[i]>0) {
        if (toReturn == -10000) toReturn = values[i];
        else if (slotTypes[i-1] != 0) toReturn = doMath(values[i-1], values[i], slotMathTypes[i]);
      }
    }

    if (toReturn == -10000) return 0;

    return toReturn;
  }

  Node getCopy() {
    ArrayList<Float> copiedFloats = new ArrayList<Float>();
    for (int i = 0; i < floatValues.size(); i++) {
      copiedFloats.add(floatValues.get(i));
    }
    ArrayList<Node> copiedNodes = new ArrayList<Node>();
    for (int i = 0; i < nodeChildren.size(); i++) {
      copiedNodes.add(nodeChildren.get(i).getCopy());
    }

    return new Node(slotTypes.clone(), slotMathTypes.clone(), copiedFloats, copiedNodes);
  }

  float doMath(float a, float b, int _type) {
    float toReturn = 0;

    switch(_type) {
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
