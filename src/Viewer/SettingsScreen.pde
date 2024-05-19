class SettingsScreen {

  boolean connecting = false;

  Slider nVariablesSlider;
  int previousNVariables;

  String[] sourceJackLabels = {"mouseX", "mouseY", "sine", "perlin"};
  Jack[] sourceJacks = new Jack[sourceJackLabels .length];
  ArrayList<Jack> destinationJacks = new ArrayList<Jack>();

  SettingsScreen() {
    nVariablesSlider = new Slider(width/2 - width/4/2, gap * 3, width/4);
    previousNVariables = getNVariables();

    float sourceJackX = nVariablesSlider.x;
    float destinationJackX = sourceJackX + nVariablesSlider.w;

    for (int i = 0; i < sourceJacks.length; i++) {
      sourceJacks[i] = new Jack(sourceJackX, getJackY(i), true);
      sourceJacks[i].setLabel(sourceJackLabels[i]);
    }

    for (int i = 0; i < previousNVariables; i++) {
      destinationJacks.add(new Jack(destinationJackX, getJackY(i), false));
    }
  }

  void show() {
    background(10);

    int currentNVariables = getNVariables();
    checkNVariablesChange(currentNVariables);

    textAlign(LEFT, CENTER);
    textSize(12);
    text("N Variables: " + currentNVariables, nVariablesSlider.x, nVariablesSlider.y - gap);
    nVariablesSlider.show();

    for (int i = 0; i < sourceJacks.length; i++) {
      sourceJacks[i].show();
    }

    for (int i = 0; i < destinationJacks.size(); i++) {
      destinationJacks.get(i).show();
    }
  }

  void checkNVariablesChange(int _currentNVariables) {

    if (_currentNVariables == destinationJacks.size()) return;

    if (_currentNVariables > destinationJacks.size()) {
      while (_currentNVariables > destinationJacks.size()) {
        destinationJacks.add(new Jack(nVariablesSlider.x + nVariablesSlider.w, getJackY(destinationJacks.size()), false));
      }
    } else {
      while (_currentNVariables < destinationJacks.size()) {
        if (destinationJacks.size() < 1) return;
        destinationJacks.remove(destinationJacks.size()-1);
      }
    }
  }

  float getJackY (int _index) {
    return (nVariablesSlider.y + gap*2 + (_index * (gap + 16)));
  }

  int getNVariables() {
    return int(nVariablesSlider.value * 10);
  }
}
