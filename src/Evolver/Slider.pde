class Slider {

  float x, y, w;
  float value = 0.5;
  float lineWeight = 6;
  float thumbWeight = 18;
  boolean enabled = true;
  int nTicks = 0;

  Slider(float _w) {
    w =_w;
  }

  Slider(float _x, float _y, float _w) {
    x = _x;
    y = _y;
    w = _w - lineWeight;
  }

  void update() {
    if (!enabled) return;

    if (mousePressed && detectHover()) {
      float inputValue =  map(mouseX, screenX(x, y), screenX(w, 0), 0, 1);
      value = constrain(inputValue, 0, 1);
      if (nTicks > 0) {
        lockAtTick();
      }
    }
  }

  void show() {
    update();

    strokeWeight(lineWeight);

    stroke(colors.get("surfacevariant"));

    line(x+lineWeight/2, y, x+w, y);

    if (!enabled) {
      stroke(colors.get("primaryopacity"));
    } else if (detectHover()) {
      stroke(colors.get("secondary"));
    } else {
      stroke(colors.get("primary"));
    }

    float visualW = map(value, 0, 1, lineWeight/2, w);

    line(x+lineWeight/2, y, x+visualW, y);

    if (nTicks > 0 && enabled) {

      //stroke(colors.get("surfacevariant"));
      strokeWeight(lineWeight / 3);
      for (int i = 0; i < nTicks + 1; i ++) {
        float tickX = w * (i * (1.0 / (nTicks + 1)));

        if (tickX > visualW) {
          stroke(colors.get("primary"));
        } else {
          stroke(colors.get("surfacevariant"));
        }

        point(x+tickX, y);
      }
    }

    if (!enabled) {
      return;
    } else if (detectHover()) {
      stroke(colors.get("secondary"));
    } else {
      stroke(colors.get("primary"));
    }

    strokeWeight(thumbWeight);

    point(x+visualW, y);
  }

  void lockAtTick() {
    float closestValue = 0;
    float minimalDifference = value - 0;

    float tickGap = 1.0 / (nTicks + 1);
    
    for (int i =0; i < nTicks + 2; i ++) {
      float possibleTickValue = i * tickGap;
      float possibleDifference = abs(value - possibleTickValue);

      if (possibleDifference < minimalDifference) {
        closestValue = possibleTickValue;
        minimalDifference = possibleDifference;
      }
    }

    value = closestValue;
  }

  boolean detectHover() {
    if (mouseX < screenX(x - thumbWeight, y))return false; //screenX and screenY because of translations
    if (mouseX > screenX(w+x + thumbWeight, y))return false;
    if (mouseY < screenY(x, y - thumbWeight)) return false;
    if (mouseY > screenY(x, y + thumbWeight)) return false;

    return true;
  }
  
  void setNTicks(int _nTicks){
    if(_nTicks <1) return;
    nTicks = _nTicks;
    lockAtTick();    
  }

  void setValue(float _value) {
    value = _value;
  }

  void setEnabled(boolean _state) {
    enabled = _state;
  }
}
