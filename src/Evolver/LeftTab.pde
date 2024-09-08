/*

 Handles the UI tab on the left of the screen.
 
 When in population screen it includes:
 - Variables (if enabled)
 - Aspect ratio
 - Song controls
 - Generation controller
 
 When in population screen it includes:
 - Variables (if enabled)
 - Song controls
 - Layout Controller (toggle tree & image)
 - Individual related actions (fullscreen, export, more fitness, less fitness)
 - List of functions used in individual
 */

class LeftTab {

  boolean enabled = true;
  boolean state = false; //false - population, true - individual
  boolean hidden = false;
  int columnWidth = 2;
  String nodeInfoString;

  BackController backController = new BackController();
  AspectRatioController aspectRatioController = new AspectRatioController();
  DimensionsController dimensionsController = new DimensionsController();
  VariablesController variablesController;
  MusicController musicController = new MusicController();
  GenerationController generationController = new GenerationController();
  LayoutController layoutController = new LayoutController();
  IndividualController individualController = new IndividualController();

  LeftTab(int _nVariables) {
    variablesController = new VariablesController(_nVariables);
  }

  void show() {
    if (getFullscreen()) {

      return;
    }
    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, columns[columnWidth-1].y, height);

    pushMatrix();

    translate(border, border);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Back", 0, 0);
    translate(0, gap);
    backController.show();

    translate(0, gap + backController.totalHeight);
    fill(colors.get("primary"));

    if (variablesController.nVariables > 0) {
      textAlign(LEFT, CENTER);
      textFont(fonts.get("medium"));
      textSize(14);
      text("Variables", 0, 0);
      variablesController.show();

      translate(0, gap + variablesController.totalHeight);
    }

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);

    if (false) {
      text("Aspect Ratio: " + nf(aspectRatio, 0, 2), 0, 0);
      translate(0, gap);
      aspectRatioController.show();
      aspectRatio = 0.5 + 1.5 * aspectRatioController.aspectRatio.value;
      translate(0, gap + aspectRatioController.totalHeight);
    }
    
    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Output Dimensions", 0, 0);
    translate(0, gap);
    dimensionsController.show();
    aspectRatio = 1.0* dimensionsController.getWidth()/dimensionsController.getHeight();
    imageExportWidth = dimensionsController.getWidth();
    imageExportHeight = dimensionsController.getHeight();
    translate(0, gap + dimensionsController.totalHeight);

    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    text("Music", 0, 0);
    translate(0, gap);
    musicController.show();

    translate(0, gap + musicController.totalHeight);
    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("medium"));
    textSize(14);
    if (screen.equals("population")) {
      text("Generation: " + population.nGenerations, 0, 0);
      translate(0, gap);
      generationController.show();
    } else {
      text("Layout", 0, 0);
      translate(0, gap);
      layoutController.show();


      translate(0, gap + layoutController.totalHeight);
      fill(colors.get("primary"));
      textAlign(LEFT, CENTER);
      textFont(fonts.get("medium"));
      textSize(14);
      if (individualScreen.individual!= null) text("Individual: " + nf(individualScreen.individual.getFitness(), 0, 1)  + " fitness", 0, 0);
      else text("Individual", 0, 0);
      translate(0, gap);
      individualController.show();

      if (individualScreen.individual!= null) {
        translate(0, gap + individualController.totalHeight);
        fill(colors.get("primary"));
        textAlign(LEFT, CENTER);
        textFont(fonts.get("medium"));
        textSize(14);
        text("Operation Types", 0, 0);
        textFont(fonts.get("light"));
        textSize(12);
        textAlign(LEFT, TOP);
        translate(0, gap);
        text(individualScreen.nodeInfoString, 0, 0, columns[columnWidth-1].z * 2 - border - gap, 200);
      }
    }

    popMatrix();
  }

  float getSliderValue(int _sliderIndex) {
    return variablesController.getSliderValue(_sliderIndex);
  }

  Boolean getBack() {
    return backController.back.getSelected();
  }

  Boolean[] getLayout() {
    Boolean[] toReturn = {layoutController.image.toggled, layoutController.tree.toggled};
    return toReturn;
  }

  Boolean getEvolve() {
    return generationController.evolve.getSelected();
  }
  
  Boolean getLoadPreviousGeneration(){
    return generationController.left.getSelected();
  }
  
  Boolean getLoadNextGeneration(){
    return generationController.right.getSelected();
  }

  Boolean getTreeButtonHover() {
    return layoutController.tree.hovered;
  }

  Boolean getFullscreen() {
    if (!mousePressed) return false;
    return individualController.fullscreen.hovered == mousePressed;
  }
}

//controls back button
class BackController {
  IconButton back;
  int totalHeight = 40;

  BackController() {
    int buttonW = 40;
    back = new IconButton(0, 0, buttonW, "back");
  }

  void show() {
    back.show();
  }
}

//controls interactive variables
class VariablesController {
  int nVariables;
  int nTypes = 4;
  Icon[] icons;
  Slider[] sliders;
  ToggleButton[][] toggles;

  int totalHeight = 0;

  VariablesController(int _nVariables) {
    nVariables = _nVariables;

    if (nVariables < 1) return;

    icons = new Icon[nTypes];
    String[] iconNames = {"horizontal", "vertical", "wave", "perlin"};
    String[] iconTooltips = {"horizontal mouse movement", "vertical mouse movement", "sine wave", "perlin noise"};
    sliders = new Slider[_nVariables];
    toggles = new ToggleButton[_nVariables][nTypes]; // [horizontal] / [vertical]

    ToggleButton temp = new ToggleButton(0, 0);
    float toggleW = temp.w;
    float togglesGapH = (columns[0].z - gap - (toggles[0].length * toggleW)) / (toggles[0].length - 1);

    //creating items
    float incY = gap * 1.5;
    float currentX = columns[0].z;
    float currentY = incY;
    for (int i = 0; i < _nVariables; i++) {
      sliders[i] = new Slider(0, currentY + toggleW/2, columns[0].z - gap);
      variablesManager.switchType(i, -1);

      for (int j = 0; j < toggles[0].length; j++) {
        icons[j] = new Icon(currentX, 0, gap, iconNames[j]);
        icons[j].setTooltipText(iconTooltips[j]);
        toggles[i][j] = new ToggleButton(currentX, currentY);
        currentX += toggleW + togglesGapH;
      }
      currentY += incY;
      currentX = columns[0].z;
    }

    totalHeight = ceil(currentY);
  }

  void show() {
    if (nVariables < 1) return;

    for (int i = 0; i < sliders.length; i++) {
      if (!sliders[i].enabled) {
        sliders[i].setValue(variablesManager.getVariable(i));
      }
      sliders[i].show();


      for (int j = 0; j < toggles[0].length; j++) {
        icons[j].show();
        toggles[i][j].show();

        if (toggles[i][j].getSelected()) {
          toggles[i][j].toggle();

          if (toggles[i][j].toggled) {
            untoggleToggles(i, j);
            sliders[i].setEnabled(false);
            variablesManager.switchType(i, j);
          } else {
            variablesManager.switchType(i, -1);
            sliders[i].setEnabled(true);
          }
        }
      }
    }
  }

  void untoggleToggles(int _row, int _column) {
    if (nVariables < 1) return;

    for (int i = 0; i < toggles[_row].length; i++) {
      if (i != _column) {
        toggles[_row][i].toggled = false;
      }
    }
  }

  float getSliderValue(int _sliderIndex) {
    if (nVariables < 1) return 0;

    return sliders[_sliderIndex].value;
  }
}

//controls aspect ratio, deprecated
class AspectRatioController {
  Slider aspectRatio;

  int totalHeight = 40;

  AspectRatioController() {
    aspectRatio = new Slider(columns[0].z - gap);
    aspectRatio.value = 0.66;
  }

  void show() {
    pushMatrix();
    translate(0, 20);
    aspectRatio.show();
    popMatrix();
  }
}

//controls output dimensions in pixels
class DimensionsController {
   Slider widthSlider;
   Slider heightSlider;
  
  int totalHeight = 60;
  
  DimensionsController(){
    float sliderValue = (1920 - minExportResolution * 1.0) / (maxExportResolution - minExportResolution * 1.0);
    widthSlider = new Slider(columns[0].z - gap);
    widthSlider.value = sliderValue;
    heightSlider = new Slider(columns[1].z - gap);
    heightSlider.value = sliderValue;
    
  }
  
  void show(){
    fill(colors.get("primary"));
    textAlign(LEFT, CENTER);
    textFont(fonts.get("light"));
    textSize(14);
    
    pushMatrix();
    translate(0, 14);
    text("Width: " + getWidth() + "px", 0,0); 
    translate(columns[0].z, 0);
    text("Height: " + getHeight() + "px", 0,0); 
    popMatrix();
    
    pushMatrix();
    translate(0, 50);
    widthSlider.show();
    translate(columns[0].z, 0);
    heightSlider.show();
    popMatrix();
  }
  
  int getWidth(){
    float value = widthSlider.value * (maxExportResolution - minExportResolution) + minExportResolution;
    return round(value / 10) * 10;
  }
  
  int getHeight(){
    float value = heightSlider.value * (maxExportResolution - minExportResolution) + minExportResolution;
    return round(value / 10) * 10;
  }
}

//controls music playback, skip, pause, volume
class MusicController {

  IconButton previous;
  IconButton play;
  IconButton next;

  Slider volume;

  int totalHeight = 40;

  MusicController() {
    int buttonW = 40;
    float buttonGap = (columns[0].z - buttonW * 3 - gap) / 2;

    previous = new IconButton(0, 0, buttonW, "previous");
    play = new IconButton(buttonGap + buttonW, 0, buttonW, "play");
    next = new IconButton((buttonGap + buttonW) * 2, 0, buttonW, "next");

    volume = new Slider(columns[0].z - gap);
  }

  void show() {
    previous.show();
    play.show();
    next.show();
    
    pushMatrix();
    translate(columns[0].z, 20);
    volume.show();
    setSoundVolume(volume.value);
    popMatrix();

    if (play.getSelected()) {
      //play/pause music
      play.toggle();
      //toggleMuteSong();
      togglePauseSong();
      
      if (play.toggled) {
        play.setIcon("play");
      } else {
        play.setIcon("pause");
      }
    }

    if (previous.getSelected())
    {
      changeSong(false);
      play.setIcon("pause");
      play.toggled = false;
    } else if (next.getSelected())
    {
      changeSong(true);
      play.setIcon("pause");
      play.toggled = false;
    }
  }
}

//evolve button
class GenerationController {

  IconButton left;
  IconButton tree;
  IconButton right;

  TextButton evolve;

  int totalHeight = 40;

  GenerationController() {
    int buttonW = 40;
    float buttonGap = (columns[0].z - buttonW * 3 - gap) / 2;

    left = new IconButton(0, 0, buttonW, "left");
    //tree = new IconButton(buttonGap + buttonW, 0, buttonW, "tree");
    right = new IconButton((buttonGap + buttonW) * 2, 0, buttonW, "right");

    //left.disabled = true;
    //right.disabled = true;

    evolve = new TextButton(columns[0].z, 0, 0, 0, "Evolve");
    //evolve = new TextButton(0, 0, 0, 0, "Evolve");

  }

  void show() {
    left.show();
    //tree.show();
    right.show();

    pushMatrix();
    float evolveGapLeft = (columns[0].z - evolve.w - gap) / 2;
    translate(evolveGapLeft, 0);
    evolve.show();
    popMatrix();
  }
}

class LayoutController {

  IconButton image;
  IconButton tree;

  int totalHeight = 40;

  LayoutController() {
    int buttonW = 40;
    float buttonGap = (columns[0].z - buttonW * 3) / 2;

    image = new IconButton(0, 0, buttonW, "image");
    tree = new IconButton(buttonW + buttonGap, 0, buttonW, "tree");
    tree.toggled = false;
  }

  void show() {
    image.show();
    tree.show();

    if (image.getSelected()) {
      image.toggle();
      if (!image.toggled && !tree.toggled) tree.toggle();
    } else if (tree.getSelected()) {
      tree.toggle();
      if (!image.toggled && !tree.toggled) image.toggle();
    }
  }
}

class IndividualController {

  IconButton fullscreen;
  IconButton download;
  IconButton plus;
  IconButton minus;

  int totalHeight = 40;

  IndividualController() {
    int buttonW = 40;
    float buttonGap = (columns[0].z - buttonW * 3) / 2;

    fullscreen = new IconButton(0, 0, buttonW, "fullscreen");
    download = new IconButton(buttonW + buttonGap, 0, buttonW, "download");
    minus = new IconButton(buttonW * 2 + buttonGap * 2, 0, buttonW, "minus");
    plus = new IconButton(buttonW * 3 + buttonGap * 3, 0, buttonW, "plus");
  }

  void show() {
    fullscreen.show();
    download.show();
    minus.show();
    plus.show();

    if (download.getSelected()) {
      exportShader(individualScreen.individual);
      exportImage(individualScreen.individual);
    } else if (minus.getSelected()) {
      individualScreen.individual.removeFitness();
    } else if (plus.getSelected()) {
      individualScreen.individual.giveFitness();
    }
  }
}
