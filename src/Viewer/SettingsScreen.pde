class SettingsScreen {

  Slider nVariablesSlider;
  int previousNVariables;

  String[] sourceJackLabels = {"mouseX", "mouseY", "sine", "perlin"};
  Jack[] sourceJacks = new Jack[sourceJackLabels .length];
  ArrayList<Jack> destinationJacks = new ArrayList<Jack>();

  boolean connecting = false;
  ArrayList<Connection> connections = new ArrayList<Connection>();
  Connection ongoingConnection;

  SettingsScreen() {
    nVariablesSlider = new Slider(width/2 - width/4/2, gap * 3, width/4);
    previousNVariables = getNVariables();

    float sourceJackX = nVariablesSlider.x;
    float destinationJackX = sourceJackX + nVariablesSlider.w;

    for (int i = 0; i < sourceJacks.length; i++) {
      sourceJacks[i] = new Jack(sourceJackX, getJackY(i), true, i);
      sourceJacks[i].setLabel(sourceJackLabels[i]);
    }

    for (int i = 0; i < previousNVariables; i++) {
      destinationJacks.add(new Jack(destinationJackX, getJackY(i), false, i));
    }
    
    variablesManager.setNVariables(getNVariables());
    setVariableTypes();
  }

  void show() {
    background(10);

    int currentNVariables = getNVariables();
    checkNVariablesChange(currentNVariables);

    textAlign(LEFT, CENTER);
    textSize(16);
    text("N Variables: " + currentNVariables, nVariablesSlider.x, nVariablesSlider.y - gap);
    nVariablesSlider.enabled = !connecting;
    nVariablesSlider.show();

    for (int i = 0; i < sourceJacks.length; i++) {
      sourceJacks[i].show();
      if (sourceJacks[i].detectHover()) {
        if (!connecting && mousePressed) {
          startConnection(sourceJacks[i]);
        } else if (connecting && !mousePressed) {
          endConnection(sourceJacks[i]);
        }
      }
    }

    for (int i = 0; i < destinationJacks.size(); i++) {
      destinationJacks.get(i).setLabel(nf(variablesManager.getVariable(i), 0, 3));
      destinationJacks.get(i).show();
      if (destinationJacks.get(i).detectHover()) {
        if (!connecting && mousePressed) {
          startConnection(destinationJacks.get(i));
        } else if (connecting && !mousePressed) {
          endConnection(destinationJacks.get(i));
        }
      }
    }

    if (!mousePressed) {
      connecting = false;
    }

    if (connecting) {
      ongoingConnection.show();
    }

    for (int i = 0; i < connections.size(); i ++) {
      connections.get(i).show();
    }
  }

  void checkNVariablesChange(int _currentNVariables) {

    if (_currentNVariables == destinationJacks.size()) return;

    if (_currentNVariables > destinationJacks.size()) {
      while (_currentNVariables > destinationJacks.size()) {
        destinationJacks.add(new Jack(nVariablesSlider.x + nVariablesSlider.w, getJackY(destinationJacks.size()), false, destinationJacks.size()));
      }
    } else {
      while (_currentNVariables < destinationJacks.size()) {
        if (destinationJacks.size() < 1) return;
        for (int i = 0; i < connections.size(); i ++) {
          if (connections.get(i).destination == destinationJacks.get(destinationJacks.size()-1)) connections.remove(i);
        }
        destinationJacks.remove(destinationJacks.size()-1);
      }
    }
    
    variablesManager.setNVariables(_currentNVariables);
    setVariableTypes();
  }

  void startConnection(Jack _jack) {
    connecting = true;
    ongoingConnection = new Connection(_jack);
  }

  void endConnection(Jack _jack) {
    connecting = false;

    if (_jack == ongoingConnection.source || _jack == ongoingConnection.destination) { //if same jack as connection started
      ongoingConnection = null;
      return;
    }

    boolean connectionIsGood = false;

    if (ongoingConnection.source != null) {
      if (ongoingConnection.source.isSource != _jack.isSource) { //if both jacks are different types
        ongoingConnection.setJack(_jack);
        connectionIsGood = true;
      }
    } else if (ongoingConnection.destination != null) {
      if (ongoingConnection.destination.isSource != _jack.isSource) { //if both jacks are different types
        ongoingConnection.setJack(_jack);
        connectionIsGood = true;
      }
    }

    if (!connectionIsGood) return;

    for (int i = 0; i < connections.size(); i ++) {
      if (connections.get(i).destination == ongoingConnection.destination) connections.remove(i);
    }

    connections.add(ongoingConnection);
    setVariableTypes();
  }
  
  void setVariableTypes(){
    for(int i = 0; i < connections.size(); i++){
      if(!connections.get(i).checkConnected()) continue;
        variablesManager.switchType(connections.get(i).destination.index, connections.get(i).source.index);
    }
  }

  float getJackY (int _index) {
    return (nVariablesSlider.y + gap*2 + (_index * (gap + 16)));
  }

  int getNVariables() {
    return int(nVariablesSlider.value * 10);
  }
}
