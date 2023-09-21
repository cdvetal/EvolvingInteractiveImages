int maxDepth = 30;

void setup(){
 size(1080, 1080);
 colorMode(RGB, 1);
 
 Individual ind = new Individual();
 
 for(int i = 0; i < width; i++){
   println((float)i/width * 100);
   for(int j = 0; j < height; j++){
     PVector rgb = ind.getColor((float)i/width, (float)j/height);
     
     color c = color(rgb.x, rgb.y, rgb.z);
     
     set(i,j,c);
   }
 }
}

void draw(){
  
}

void mousePressed(){
 save("imgs/img_"+month()+"M_"+day()+"D_"+hour()+"h_"+minute()+"m_"+second()+"s"+".png");
 exit();
}
