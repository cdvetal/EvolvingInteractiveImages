class Icon{
 
  float x,y,w;
  PShape icon = null;
  
  Icon(float _w, String _iconName){
    w = _w;
    if (icons.containsKey(_iconName)) {
      icon = icons.get(_iconName);
    }
  }
  
  Icon(float _x, float _y, float _w, String _iconName){
    x = _x;
    y = _y;
    w = _w;
    if (icons.containsKey(_iconName)) {
      icon = icons.get(_iconName);
    }
  }
  
  void setCoordinates(float _x, float _y){
    x = _x;
    y = _y;
  }
  
  void show(){
    if(icon == null) return;
    
    icon.disableStyle();
    fill(colors.get("primary"));
    strokeWeight(1);
    stroke(0, 0, 0, 0); //invisible stroke, fixes svg bug with bounding box

    shapeMode(CENTER);
    shape(icon, x + w/2, y + w/2, w*0.6, w*0.6);
  }
  
}
