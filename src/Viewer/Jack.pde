class Jack { //point that gets connected (female)

  float x, y, w = 16;
  int strokeWeight = 4;

  String label;
  int index;

  boolean isSource;

  Jack(float _x, float _y, boolean _isSource, int _index) {
    x = _x;
    y = _y;
    isSource = _isSource;
    index = _index;
  }

  void show() {
    if (label != null) {
      fill(255);
      textSize(12);

      if (isSource) {
        textAlign(RIGHT, CENTER);
        text(label, x - gap, y + w/2);
      } else {
        textAlign(LEFT, CENTER);
        text(label, x + gap, y + w/2);
      }
    }


    noFill();
    stroke(150);
    if (detectHover()) stroke(255);
    strokeWeight(strokeWeight);
    rect(x, y, w, w);
  }

  void setLabel(String _label) {
    label = _label;
  }

  void setIndex(int _index) {
    index = _index;
  }

  boolean detectHover() {
    if (mouseX < screenX(x - strokeWeight, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(x + w + strokeWeight, 0))return false;
    if (mouseY < screenY(0, y + strokeWeight)) return false;
    if (mouseY > screenY(0, y + w + strokeWeight)) return false;

    return true;
  }
}

class Connection {

  Jack source, destination;

  Connection(Jack _jack) {
    setJack(_jack);
  }

  void setJack(Jack _jack) {
    if (_jack.isSource) source = _jack;
    else destination = _jack;
  }

  void show() {
    if (source != null && destination != null) {
      line(source.x + 8, source.y + 8, destination.x + 8, destination.y + 8);
    } else if (source == null) {
      line(destination.x + 8, destination.y + 8, mouseX, mouseY);
    } else if (destination == null) {
      line(source.x + 8, source.y + 8, mouseX, mouseY);
    }
  }

  boolean checkConnected() {
    return (source != null && destination != null);
  }
}
