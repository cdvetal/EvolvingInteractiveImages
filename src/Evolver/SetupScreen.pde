class SetupScreen {

  OperationController operationController = new OperationController();
  BackController backController = new BackController();
  AlgorithmController algorithmController = new AlgorithmController();
  StartController startController = new StartController();

  void show() {
    if (backController.back.getSelected()) {
      screen = "mainmenu";
      return;
    }
    if (startController.start.getSelected()){
      startEvolution();
      return;
    }

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
    translate(0, gap*1.5);

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
    
    //Start
    pushMatrix();

    translate(columns[9].x, border);

    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, columns[0].z, height - border - border);

    translate(gap, gap);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Start", 0, 0);
    translate(0, gap);

    startController.show();
    popMatrix();
  }
  
  void startEvolution(){
    populationSize = round(algorithmController.getSliderValue(0));
    mutationRate = algorithmController.getSliderValue(1);
    crossoverRate = algorithmController.getSliderValue(2);
    tournamentSize = round(algorithmController.getSliderValue(3));
    eliteSize = round(algorithmController.getSliderValue(4));
    
    population = new Population();
    population.initialize();
    populationScreen = new PopulationScreen(population);
    screen = "population";
  }
}

class AlgorithmController {
  Slider[] algorithmSliders;
  String[] labels = {"Population Size", "Mutation Rate", "Crossover Rate", "Tournament Size", "Elite Size"};
  PVector[] limits ={new PVector(6, 30), new PVector(0, 1), new PVector(0, 1), new PVector(1, 5), new PVector(0, 3)};
  boolean[] isInt = {true, false, false, true, true};
  //HashMap <String,PVector> settings = new HashMap <String,PVector>();

  AlgorithmController() {
    algorithmSliders = new Slider[labels.length];

    for (int i = 0; i < algorithmSliders.length; i++) {
      algorithmSliders[i] = new Slider(columns[0].z * 2 - gap);
    }
  }

  void show() {
    pushMatrix();
    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("light"));
    textSize(12);
    for (int i = 0; i < algorithmSliders.length; i ++) {
      float sliderValue = getSliderValue(i);
      String labelValue = isInt[i] ? nf(round(sliderValue), 0, 0) : nf(sliderValue, 0, 3);
      String label = labels[i]+ ": " + labelValue;
      text(label, 0, 0);
      translate(0, gap);
      algorithmSliders[i].show();
      translate(0, gap*1.5);
    }
    popMatrix();
  }
  
  float getSliderValue(int _sliderIndex){
    return (limits[_sliderIndex].y - limits[_sliderIndex].x) * algorithmSliders[_sliderIndex].value + limits[_sliderIndex].x;
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
      String explanation = operations[i].explanation == null ? "" : ": " + operations[i].explanation;
      text(operations[i].operator + explanation, operationToggles[i].x + gap*2, operationToggles[i].y);
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

class StartController {
  TextButton start;

  StartController() {
    start = new TextButton(0, 0, 0, 0, "Start");
  }

  void show() {
    start.show();
  }
}
