/*

Simple UI popup to show feedback on certian actions.

*/

class Popup {

  float x = width/2, y = height * 0.9;
  float w, h = gap * 3;
  String message;
  
  int duration = 4000; //in ms
  int startMS;
  float currentOpacity;
  
  
  
  void setPopup(String _msg){
    startMS = millis();
    currentOpacity = 1;
    
    message = _msg;
    
    textSize(14);
    w = textWidth(message) + gap * 2;
  }
  
  void show(){
    if(millis() - duration > startMS) return;
    noStroke();
    
    fill(colors.get("surface"));
    rect(x - w/2, y - h/2, w, h);
    
    textAlign(CENTER, CENTER);
    textSize(14);
    
    fill(colors.get("primary"));
    text(message, x, y);
  }
}
