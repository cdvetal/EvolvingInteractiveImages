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

/////

float getLeftMostBodyNormalised() {
  if (bodies.size() < 1) return 0.5;
  
  float mostLeftValue = bodies.get(0).centroidX;
   
  for (int i = 0; i < bodies.size(); i++) {
    if (bodies.get(i).centroidX < mostLeftValue){
      mostLeftValue = bodies.get(i).centroidX;
    }
  }
  
  float normalised = mostLeftValue / (float)frameWidth;
  
  return normalised;
}

float getRightMostBodyNormalised() {
  if (bodies.size() < 1) return 0.5;
  
  float mostRightValue = bodies.get(0).centroidX;
   
  for (int i = 0; i < bodies.size(); i++) {
    if (bodies.get(i).centroidX > mostRightValue){
      mostRightValue = bodies.get(i).centroidX;
    }
  }
   
  float normalised = ((float)mostRightValue / frameWidth);
  
  return normalised;
}

float getBodyXAverageNormalised() {
  if (bodies.size() < 1) return 0.5;
  
  float sum = 0;
   
  for (int i = 0; i < bodies.size(); i++) {
    sum += bodies.get(i).centroidX;
  }
  
  float average = (float)sum / bodies.size();
  
  return ((float)average / frameWidth);
}

float getBodyYAverageNormalised() {
  if (bodies.size() < 1) return 0.5;
  
  float sum = 0;
   
  for (int i = 0; i < bodies.size(); i++) {
    sum += bodies.get(i).centroidY;
  }
  
  float average = (float)sum / bodies.size();
  
  return ((float)average / frameWidth);
}
