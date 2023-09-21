class Individual{
 Node[] nodes = new Node[3];
 int[] breadthTracker;
 
 Individual(){
     breadthTracker = new int[maxDepth];
  for(int i = 0; i < 3; i++){
   nodes[i] = new Node(0, this); 
  }
 }
 
 PVector getColor(float _x, float _y){
  float r = nodes[0].getValue(_x, _y); 
  float g = nodes[1].getValue(_x, _y); 
  float b = nodes[2].getValue(_x, _y); 
  
  return new PVector(r,g,b);
 }
 
 int getNextBreadth(int _depth){
   int toReturn = breadthTracker[_depth];
   breadthTracker[_depth] ++;
   return toReturn;
 }

}
