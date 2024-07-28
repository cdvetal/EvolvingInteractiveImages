/*

Handles screen where users can choose settings for the evolutionary run, such as:
- Genetic Algorithm values
- Number of Variables
- Max Tree Depth
- Function Set

*/

class SetupScreen {

  OperationController operationController = new OperationController();
  BackController backController = new BackController();
  AlgorithmController algorithmController = new AlgorithmController();
  StartController startController = new StartController();

  Slider nVariablesSlider;
  int maxVariables = 10;
  Slider maxDepthSlider;
  int minDepth = 1, maxDepth = 30;

  SetupScreen() {
    float sliderW = columns[0].z * 2 - gap;
    //aspectRatioSlider = new Slider(sliderW);
    //aspectRatioSlider.value = 0.66;
    nVariablesSlider = new Slider(sliderW);
    nVariablesSlider.value = 0.3;
    nVariablesSlider.setNTicks(maxVariables);
    maxDepthSlider = new Slider(sliderW);
    maxDepthSlider.value = 0.3;
    maxDepthSlider.setNTicks(maxDepth - minDepth);
  }

  void show() {
    if (backController.back.getSelected()) {
      screen = "mainmenu";
      return;
    }
    if (startController.start.getSelected()) {
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

    //NVariables & MaxDepth
    pushMatrix();

    translate(columns[3].x, border);
    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, columns[0].z*2 + gap, height - border - border);

    translate(gap, gap);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Number of Variables: " + getNVariables(), 0, 0);
    translate(0, gap);

    nVariablesSlider.show();

    translate(0, gap);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Max Tree Depth: " + getMaxDepth(), 0, 0);
    translate(0, gap);

    maxDepthSlider.show();

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
    translate(0, gap * 2);

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

  void startEvolution() {
    //aspectRatio = 0.5 + 1.5 * aspectRatioSlider.value;

    enabledOperations = operationController.getEnabledOperations();

    boolean varEnabled = checkVarEnabled(enabledOperations);
    int nVariables = varEnabled ? getNVariables() : 0; //if outside variables is disabled, then 0 variables to manage

    variablesManager = new VariablesManager(nVariables);

    leftTab = new LeftTab(nVariables);

    maxTreeDepth = getMaxDepth();

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

  int getNVariables() {
    return int(round(nVariablesSlider.value * maxVariables));
  }

  int getMaxDepth() {
    return int(floor(minDepth + maxDepthSlider.value * (maxDepth - minDepth)));
  }

  boolean checkVarEnabled(Operation[] _enabledOperations) {
    for (Operation op : _enabledOperations) {
      if (op.operator == "var") return true;
    }
    return false;
  }
}


class AlgorithmController {
  Slider[] algorithmSliders;
  String[] labels = {"Population Size", "Mutation Rate", "Crossover Rate", "Tournament Size", "Elite Size"};
  Float[] defaultValues = {0.5, 0.4, 0.3, 0.5, 0.33};
  PVector[] limits ={new PVector(6, 30), new PVector(0, 1), new PVector(0, 1), new PVector(1, 5), new PVector(0, 3)};
  boolean[] isInt = {true, false, false, true, true};

  AlgorithmController() {
    algorithmSliders = new Slider[labels.length];

    for (int i = 0; i < algorithmSliders.length; i++) {
      algorithmSliders[i] = new Slider(columns[0].z * 2 - gap);
      algorithmSliders[i].value = defaultValues[i];
      algorithmSliders[i].setNTicks(int(limits[i].y - limits[i].x));
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

  float getSliderValue(int _sliderIndex) {
    return (limits[_sliderIndex].y - limits[_sliderIndex].x) * algorithmSliders[_sliderIndex].value + limits[_sliderIndex].x;
  }
}

class OperationController {

  ToggleButton[] operationToggles;

  OperationController() {
    operationToggles = new ToggleButton[operations.length];

    for (int i = 0; i < operationToggles.length; i++) {
      operationToggles[i] = new ToggleButton(0, i * gap * 2);
      operationToggles[i].toggled = operations[i].defaultToggle;
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
