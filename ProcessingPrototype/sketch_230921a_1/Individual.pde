class Individual{
 Node[] nodes = new Node[3];
 
 Individual(){
  for(int i = 0; i < 3; i++){
   nodes[i] = new Node(0); 
  }
 }
 
 PVector getColor(float _x, float _y){
  float r = nodes[0].getValue(_x, _y); 
  float g = nodes[1].getValue(_x, _y); 
  float b = nodes[2].getValue(_x, _y); 
  
  return new PVector(r,g,b);
 }

}
