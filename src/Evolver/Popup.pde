/*

Simple UI popup to show feedback on certain actions.
Simple UI Tooltip to show feedback on hovering certain items.

*/

class Popup {

  float x = width/2, y = height * 0.9;
  float w, h = gap * 3;
  String message;
  
  int duration = 4000; //in ms
  int startMS;
  
  void setPopup(String _msg){
    startMS = millis();
    
    message = _msg;
    
    textSize(14);
    w = textWidth(message) + gap * 2;
  }
  
  void show(){
    if(millis() - duration > startMS) return;
    stroke(colors.get("primary"));
    strokeWeight(1);
    
    fill(colors.get("surface"));
    rect(x - w/2, y - h/2, w, h);
    
    textFont(fonts.get("light"));
    textAlign(CENTER, CENTER);
    textSize(14);

    
    fill(colors.get("primary"));
    text(message, x, y);
  }
}



class Tooltip{
  float x, y, w, h = gap * 2;
  String message;
  
  int duration = 100; //in ms
  int startMS;
  
  void setTooltip(String _msg){
    startMS = millis();
    
    message = _msg;
    
    textSize(14);
    w = textWidth(message) + gap * 2;
    
    x = mouseX;
    y = mouseY - h;
  }
  
  void show(){
    if(millis() - duration > startMS) return;
    stroke(colors.get("primary"));
    strokeWeight(1);
    
    fill(colors.get("surface"));
    rect(x - w/2, y - h/2, w, h);
    
    textFont(fonts.get("light"));
    textAlign(CENTER, CENTER);
    textSize(14);
    
    fill(colors.get("primary"));
    text(message, x, y);
  }
}
