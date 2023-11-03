class LoadMenu {

  TextButton backButton;
  JSONObject[] runsJSON;
  TextButton[] runButtons;

  JSONObject hoveredRun = null;

  LoadMenu() {
    backButton = new TextButton(width/2 - 50, height - 250, 100, 50, "Back", 12);
    initialize();
  }

  void initialize() {
    runsJSON = loadRuns();
    PVector[][] runListGrid = calculateGrid(runsJSON.length, 100, 100, width - 200, height - 600, 25, 25, 25, false);
    runButtons = createRunButtons(runsJSON, runListGrid);
  }

  void run() {
    update();
    show();
  }

  void update() {
    backButton.update();
    if (backButton.getSelected()) {
      screen = 0;
      backButton.resetSelected();
      return;
    }

    for (int i = 0; i < runButtons.length; i ++) {
      runButtons[i].update();
      if (runButtons[i].hovered) {
        hoveredRun = runsJSON[i];
        return;
      }
    }

    hoveredRun = null;
  }

  void show() {
    backButton.show();
    showRunList();
    showHoveredRunStats();
  }

  void showRunList() {
    for (int i = 0; i < runButtons.length; i ++) {
      runButtons[i].show();
    }
  }

  void showHoveredRunStats() {
    if (hoveredRun == null) return;

    String textToShow = "";
    textToShow += "id: " + hoveredRun.getString("id");
    textToShow += "\ndate: " + hoveredRun.getString("timestamp");

    textSize(12);
    textAlign(LEFT, CENTER);
    text(textToShow, width * 0.7, height/2);
  }

  JSONObject[] loadRuns() {
    String directory = run.getRunPath();

    File f = dataFile(directory);
    String[] names = f.list();

    JSONObject[] toReturnJSON = new JSONObject[names.length];

    for (int i = 0; i < toReturnJSON.length; i ++) {
      toReturnJSON[i] = loadJSONObject(directory + names[i]);
      print(toReturnJSON[i].getString("id"));
    }

    return toReturnJSON;
  }

  TextButton[] createRunButtons(JSONObject[] _runs, PVector[][] _grid) {

    TextButton[] toReturn = new TextButton[_runs.length];

    /*
    float y = 250;
     float x = width/2 - 50;
     int w = 100;
     int h = 50;
     
     for (int i = 0; i < _runs.length; i ++) {
     toReturn[i] = new TextButton(x, y, w, h, _runs[i].getString("id"), 10);
     y += h * 1.5;
     }*/

    int row = 0;
    int col = 0;

    for (int i = 0; i < _runs.length; i++) {
      float x = _grid[row][col].x;
      float y = _grid[row][col].y;
      float d = _grid[row][col].z;

      toReturn[i] = new TextButton(x, y, d, d, _runs[i].getString("id"), 10);

      col += 1;
      if (col >= _grid[row].length) {
        row += 1;
        col = 0;
      }
    }
    return toReturn;
  }
}
