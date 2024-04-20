class SetupScreen {

  OperationController operationController = new OperationController();
  BackController backController = new BackController();
  AlgorithmController algorithmController = new AlgorithmController();
  
  SetupScreen() {
  }

  void show() {
    //Back
    pushMatrix();

    translate(border, border);
    
    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, columns[0].z, height - border - border);
    
    translate(gap, gap);
    
    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Back", 0, 0);
    translate(0, gap);
    
    backController.show();
    popMatrix();
    
    //Algorithm
    pushMatrix();
    
    translate(columns[1].x, border);
    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, columns[0].z*2 + gap, height - border - border);
    
    translate(gap, gap);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Algorithm Settings", 0, 0);
    translate(0, gap);

    algorithmController.show();
    popMatrix();
    
    //Function Set
    pushMatrix();

    translate(columns[7].x, border);
    
    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, columns[0].z*2 + gap, height - border - border);
    
    translate(gap, gap);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Function Set", 0, 0);
    translate(0, gap);

    operationController.show();
    popMatrix();
    
    
  }
}

class AlgorithmController {
  Slider[] algorithmSliders;
  String[] labels = {"Population Size", "Mutation Rate", "Crossover Rate", "Tournament Size", "Elitism"};
  
  AlgorithmController(){
    algorithmSliders = new Slider[labels.length];
    
    for(int i = 0; i < labels.length; i ++){
      algorithmSliders[i] = new Slider(columns[0].z*2 - gap);
    }
  }
  
  void show(){
    pushMatrix();
    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("light"));
    textSize(12);
    for(int i = 0; i < algorithmSliders.length; i ++){
      String label = labels[i]+ ": " + nf(algorithmSliders[i].value, 0, 3);
      text(label, 0, 0);
      translate(0, gap);
      algorithmSliders[i].show();
      translate(0, gap*1.5);
    }
    popMatrix();
  }
}

class OperationController {

  ToggleButton[] operationToggles;

  OperationController() {
    operationToggles = new ToggleButton[operations.length];

    for (int i = 0; i < operationToggles.length; i++) {
      operationToggles[i] = new ToggleButton(0, i * gap * 2);
      operationToggles[i].toggled = true;
    }
  }

  void show() {
    textAlign(LEFT, TOP);
    for (int i = 0; i < operationToggles.length; i++) {
      operationToggles[i].show();
      if (operationToggles[i].getSelected()) {
        operationToggles[i].toggle();
      }
      fill(colors.get("primary"));
      text(operations[i].operator, operationToggles[i].x + gap*2, operationToggles[i].y);
    }
  }

  Operation[] getEnabledOperations() {
    ArrayList<Operation> toReturnArrayList = new ArrayList<Operation>();

    for (int i = 0; i < operationToggles.length; i++) {
      if (operationToggles[i].toggled) toReturnArrayList.add(operations[i]);
    }

    Operation[] toReturn = new Operation[toReturnArrayList.size()];

    for (int i = 0; i < toReturn.length; i++) {
      toReturn[i] = toReturnArrayList.get(i);
    }

    return toReturn;
  }
}
