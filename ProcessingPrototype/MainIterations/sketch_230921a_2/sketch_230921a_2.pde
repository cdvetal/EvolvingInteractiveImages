int maxDepth = 40;
int seed = 0;

void setup(){
 size(420, 420);
 colorMode(RGB, 1);
 
 if(seed == 0) seed = floor(random(1000000));
 noiseSeed(seed);
 
 Individual ind = new Individual();
 
 for(int i = 0; i < width; i++){
   println(((int)((float)i/width * 100)) + "%");
   for(int j = 0; j < height; j++){
     PVector rgb = ind.getColor((float)i/width, (float)j/height);
     
     color c = color(rgb.x, rgb.y, rgb.z);
     
     set(i,j,c);
   }
 }
 
 println(seed);
}

void draw(){
  
}

void mousePressed(){
 save("imgs/imgSeed_"+seed+"_Depth_"+maxDepth+"—"+month()+"M_"+day()+"D_"+hour()+"h_"+minute()+"m_"+second()+"s"+".png");
 exit();
}
