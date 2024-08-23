class Body {

  String id;
  float centroidX, centroidY;
  float boundsX, boundsY, boundsW, boundsH;
  boolean alive;
  color randomColor;
  
  Body(String id) {
    this.id = id;
    this.alive = true;
    this.randomColor = color(random(255), random(255), random(255));
  }

  void update(float centroidX, float centroidY, float boundsX, float boundsY, float boundsW, float boundsH) {
    this.centroidX = centroidX;
    this.centroidY = centroidY;
    this.boundsX = boundsX;
    this.boundsY = boundsY;
    this.boundsW = boundsW;
    this.boundsH = boundsH;
  }

  Body getCopy() {
    Body copy = new Body(this.id);
    copy.update(this.centroidX, this.centroidY, this.boundsX, this.boundsY, this.boundsW, this.boundsH);
    copy.alive = this.alive;
    copy.randomColor = this.randomColor;
    return copy;
  }
}
