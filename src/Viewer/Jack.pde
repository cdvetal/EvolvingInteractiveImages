class Jack { //point that gets connected (female)

  float x, y, w = 16;
  
  String label;

  boolean isSource;

  Jack(float _x, float _y, boolean _isSource) {
    x = _x;
    y = _y;
    isSource = _isSource;
  }

  void show() {
    if(label != null){
      textAlign(RIGHT, CENTER);
      fill(150);
      textSize(10);
      text(label, x - gap, y + w/2);
    }
    
    noFill();
    stroke(150);
    strokeWeight(4);
    rect(x, y, w, w);
  }
  
  void setLabel(String _label){
    label = _label;
  }

  boolean detectHover() {
    if (mouseX < screenX(x, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(x + w, 0))return false;
    if (mouseY < screenY(0, y)) return false;
    if (mouseY > screenY(0, y + w)) return false;

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
      line(source.x, source.y, destination.x, destination.y);
    } else if (source == null) {
      line(destination.x, destination.y, mouseX, mouseY);
    } else if (destination == null) {
      line(source.x, source.y, mouseX, mouseY);
    }
  }

  boolean checkConnected() {
    return (source != null && destination != null);
  }
}
