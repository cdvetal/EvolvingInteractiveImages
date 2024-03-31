class Button {
  
  //add tooltip?

  boolean selected = false;
  float x, y, w, h;

  boolean hovered = false;
  boolean disabled = false; //if it can be interacted with
  boolean toggled = true;   //if it is toggled on

  void update() {
    if (hovered && mousePressed) {
      pressedButton = this; //
    }
  }

  void selected() {
    selected = true;
  }
  
  void show(){
    
  }

  boolean detectHover() {
    if (mouseX < screenX(x, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(x + w, 0))return false;
    if (mouseY < screenY(0, y)) return false;
    if (mouseY > screenY(0, y + h)) return false;

    return true;
  }

  boolean getSelected() {
    return selected;
  }

  void resetSelected() {
    selected = false;
  }
}

class TextButton extends Button {
  String text;
  float fontSize;

  int alignHorizontal = CENTER;
  int alignVertical = CENTER;

  TextButton (float _x, float _y, float _w, float _h, String _text, float _fontSize) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    text = _text;
    fontSize = _fontSize;
  }

  void show() {
    hovered = detectHover();
    
    strokeWeight(1);
    stroke(1);

    if (hovered) fill(0.5);
    else fill(0);

    rect(x, y, w, h, w);

    textSize(fontSize);
    textAlign(alignHorizontal, alignVertical);

    float xPos = 0;

    if (alignHorizontal == LEFT) xPos = 0;
    else if (alignHorizontal == CENTER) xPos = x + w/2;
    else if (alignHorizontal == RIGHT) xPos = x + w;

    fill(1);
    text(text, xPos - w/2, y  - fontSize/6, w, h);
  }
}

class IconButton extends Button {
  float iconSize;
  PShape icon = null;
  
  IconButton (float _x, float _y, float _w, String _iconName) {
    x = _x;
    y = _y;
    w = _w;
    
    if(icons.containsKey(_iconName)){
     icon = icons.get(_iconName); 
    }
    
  }
  
  void show() {
    hovered = detectHover();
    
    strokeWeight(1);
    stroke(1);

    if (hovered) fill(0.5);
    else fill(0);

    circle(x + w/2, y + w/2, w);
    
    if(icon == null) return;
    
    icon.disableStyle();
    fill(1);
    
    
    shapeMode(CENTER);
    shape(icon, x + w/2, y + w/2, w*0.6, w*0.6);
    
    fill(1,1,0);
    //rect(x + w*0.2, y + w*0.2, w*0.6, w*0.6);
  }
}
