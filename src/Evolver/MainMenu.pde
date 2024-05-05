class MainMenu {

  TextButton newRun;
  TextButton loadRun;

  MainMenu() {
    newRun = new TextButton(width/2 - 50, height/2 - 50, 100, 50, "New Run");
    loadRun = new TextButton(width/2 - 50, height/2 + 50, 100, 50, "Load Run");
  }

  void run() {
    update();
    show();
  }

  void update() {
    newRun.update();
    if (newRun.getSelected()) {
      screen = "setup";
      newRun.resetSelected();
      //population.initialize();
      return;
    }
    //loadRun.update();
    if (loadRun.getSelected()) {
      screen = "mainmenu";
      loadRun.resetSelected();
      return;
    }
  }

  void show() {
    newRun.show();
    //loadRun.show();
  }
}
