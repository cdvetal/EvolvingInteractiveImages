/*

Handles the 3 buttons in main menu:
- New Run
- Load Run
- Exit

*/

class MainMenu {

  TextButton newRun;
  TextButton loadRun;
  TextButton exit;

  MainMenu() {
    newRun = new TextButton(width/2 - 50, height/2 - 50, 100, 50, "New Run");
    loadRun = new TextButton(width/2 - 50, height/2 + 50, 100, 50, "Load Run");
    exit = new TextButton(width/2 - 50, height/2 + 50, 100, 50, "Exit");
    loadRun.disabled = true;
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
    exit.update();
    if(exit.getSelected()){
      exit();
    }
  }

  void show() {
    newRun.show();
    //loadRun.show();
    exit.show();
  }
}
