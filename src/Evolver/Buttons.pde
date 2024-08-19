/*

Handles various Button UI elements, including:
- TextButton: A button that displays text
- IconButton: A button that displays an icon
- ToggleButton: A button that can switch between two states (on/off)

*/

class Button {

  String tooltipMessage = "";

  boolean selected = false;
  float x, y, w, h;

  boolean hovered = false;
  boolean disabled = false; //if it can be interacted with
  boolean toggled = true;   //if it is toggled on

  void update() {
    if (hovered && mousePressed) {
      pressedButton = this;
    }
    if (tooltipMessage.equals(""))return;
    if (!hovered) return;
    tooltip.setTooltip(tooltipMessage);
  }

  void selected() {
    selected = true;
  }

  void show() {
  }

  boolean detectHover() {
    if (mouseX < screenX(x, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(x + w, 0))return false;
    if (mouseY < screenY(0, y)) return false;
    if (mouseY > screenY(0, y + h)) return false;

    return true;
  }

  boolean getSelected() {
    boolean toReturn = selected;
    selected = false;
    return toReturn;
  }

  void resetSelected() {
    selected = false;
  }

  void toggle() {
    toggled = !toggled;
  }

  void setValues(float _x, float _y, float _w, float _h) {
    x = _x;
    y = _y;
    w = _w;
    h = _h;
  }
  
  void setTooltip(String _text){
    tooltipMessage = _text;
  }
}

class TextButton extends Button {
  String text;
  float fontSize = 14;
  String fontWeight = null;

  int alignHorizontal = CENTER;
  int alignVertical = CENTER;

  TextButton (float _x, float _y, float _w, float _h, String _text) {
    x = _x;
    y = _y;

    if (_w == 0) {
      w = (fontSize * _text.length() * 0.47) + (gap * 2);
    } else {
      w = _w;
    }

    if (_h == 0) {
      h = (fontSize * 1.42) + 20;
    } else {
      h = _h;
    }

    text = _text;
  }

  void setFontWeight(String _weight) {
    fontWeight = _weight;
  }

  void show() {
    hovered = detectHover();
    update();

    if (hovered) {
      noStroke();
      fill(colors.get("opacity"));
      rect(x, y, w, h, w);
    } else if (!disabled) {
      stroke(colors.get("primary"));
      strokeWeight(1);
      noFill();
      rect(x, y, w, h, w);
    }

    if (fontWeight != null) textFont(fonts.get(fontWeight));
    else textFont(fonts.get("medium"));

    textSize(fontSize);
    textAlign(alignHorizontal, alignVertical);

    float xPos = 0;

    if (alignHorizontal == LEFT) xPos = 0;
    else if (alignHorizontal == CENTER) xPos = x + w/2;
    else if (alignHorizontal == RIGHT) xPos = x + w;

    if (!disabled) {
      fill(colors.get("primary"));
    } else {
      fill(colors.get("opacity"));
    }
    text(text, xPos - w/2, y  - fontSize/6, w, h);
  }
}

class IconButton extends Button {
  PShape icon = null;

  IconButton (float _x, float _y, float _w, String _iconName) {
    x = _x;
    y = _y;
    w = _w;

    if (icons.containsKey(_iconName)) {
      icon = icons.get(_iconName);
    }
  }

  void show() {
    hovered = detectHover();
    update();

    noStroke();

    if (hovered && toggled) {
      fill(colors.get("secondary"));
    } else if (hovered && !toggled) {
      fill(colors.get("opacity"));
    } else if (!toggled) {
      fill(colors.get("surfacevariant"));
    } else {
      fill(colors.get("primary"));
    }

    if (!disabled) circle(x + w/2, y + w/2, w);

    if (icon == null) return;

    icon.disableStyle();
    if (toggled) fill(colors.get("onprimary"));
    else if (!disabled) fill(colors.get("primary"));
    else fill(colors.get("opacity"));

    strokeWeight(1);
    stroke(0, 0, 0, 0); //invisible stroke, fixes svg bug with bounding box

    shapeMode(CENTER);
    shape(icon, x + w/2, y + w/2, w*0.6, w*0.6);
  }

  void setIcon(String _iconName) {
    if (icons.containsKey(_iconName)) {
      icon = icons.get(_iconName);
    }
  }

  boolean detectHover() {
    if (mouseX < screenX(x, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(x + w, 0))return false;
    if (mouseY < screenY(0, y)) return false;
    if (mouseY > screenY(0, y + w)) return false;

    return true;
  }
}

class ToggleButton extends Button {
  float w = 18;

  ToggleButton (float _x, float _y) {
    x = _x;
    y = _y;
    toggled = false;
  }

  void show() {
    hovered = detectHover();
    update();

    if (!toggled && !detectHover()) {
      strokeWeight(2);
      stroke(colors.get("surfacevariant"));
      noFill();
    } else if(!toggled && detectHover()){
      strokeWeight(2);
      stroke(colors.get("surfacevariant"));
      fill(colors.get("surfacevariant"));
    } else{
      noStroke();
      fill(colors.get("primary"));
    }
    
    rect(x, y, w, w, 2);
  }

  boolean detectHover() {
    if (mouseX < screenX(x, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(x + w, 0))return false;
    if (mouseY < screenY(0, y)) return false;
    if (mouseY > screenY(0, y + w)) return false;

    return true;
  }
}
