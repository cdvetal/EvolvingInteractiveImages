/*

Shows all the individuals in a population.
By hovering each individual you can export, analyse, add or remove fitness.

*/

class PopulationScreen {

  float x, y, w, h;
  PVector[][] individualsGrid;
  Population pop;

  IndividualHover individualHover;
  
  PShape musicIcon, videoIcon, dataIcon;

  PopulationScreen(Population _population) {
    setPopulation(_population);
    
    musicIcon = icons.get("music");
    musicIcon.disableStyle();
    videoIcon = icons.get("video");
    videoIcon.disableStyle();
    dataIcon = icons.get("sliders");
    dataIcon.disableStyle();
  }

  void setPopulation(Population _population) {
    pop = _population;
    x = columns[2].x;
    y = border;
    w = (width - border) - x;
    h = height - (border * 2);
    individualsGrid = calculateGrid(populationSize, 0, 0, w, h, 0, gap, gap, false);
    individualHover = new IndividualHover(individualsGrid[0][0].z, aspectRatio);
  }


  void show() {
    if (leftTab.getBack()) {
      screen = "setup";
      muteSong();
      return;
    } else if (leftTab.getEvolve()) {
      population.evolve();
    }

    setInputImage();
    float[] audioSpectrum = getAudioSpectrum();
    float[] variables = variablesManager.getShaderReadyVariables();

    int row = 0, col = 0;

    float gridD = individualsGrid[0][0].z, gridH = individualsGrid[0][0].z, gridW = individualsGrid[0][0].z;
    float shiftY = 0, shiftX = 0;

    if (aspectRatio > 1) {
      gridW = gridD;
      gridH = gridD/aspectRatio;
      shiftY = (gridD-gridH) / 2;
    } else {
      gridW = gridD*aspectRatio;
      gridH = gridD;
      shiftX = (gridD-gridW) / 2;
    }

    pushMatrix();
    translate(x, y);
    noFill();
    
    individualHover.setValues(gridW, gridH, shiftX, shiftY);

    //show phenotypes
    for (int i = 0; i < population.getSize(); i++) {
      float gridX = individualsGrid[row][col].x;
      float gridY = individualsGrid[row][col].y;

      //drawPhenotype(gridX + shiftX, gridY + shiftY, gridW, gridH, pop.getIndividual(i).getShader(), variables, audioSpectrum);
      image(getPhenotype(gridW, gridH, pop.getIndividual(i).getShader(), variables, audioSpectrum), gridX + shiftX, gridY + shiftY, gridW, gridH);

      stroke(colors.get("primary"));
      strokeWeight(4);
      line(gridX, gridY + gap/2 + gridH + shiftY, gridX + (gridW * pop.getIndividual(i).getFitness()), gridY + gap/2 + gridH + shiftY);
      
      pushMatrix();
      translate(gridX + shiftX, gridY + shiftY);
      showInteractiveNodeInfo(pop.getIndividual(i).operationStats);
      popMatrix();

      if (mouseX > screenX(gridX, 0) && mouseX < screenX(gridX + gridD, 0) && mouseY > screenY(0, gridY) && mouseY < screenY(0, gridY + gridD)) {
        pushMatrix();

        translate(gridX + shiftX + gridW/2, gridY + shiftY);

        individualHover.show();

        if (individualHover.checkMinus()) {
          pop.getIndividual(i).removeFitness();
        } else if (individualHover.checkPlus()) {
          pop.getIndividual(i).giveFitness();
        } else if (individualHover.checkDownload()) {
          exportShader(pop.getIndividual(i));
          exportImage(pop.getIndividual(i));
        } else if (individualHover.checkEye()) {
          individualScreen.setIndividual(pop.getIndividual(i));
          screen = "individual";
        }

        popMatrix();
      }

      col += 1;
      if (col >= individualsGrid[row].length) {
        row += 1;
        col = 0;
      }
    }

    popMatrix();
  }
  
  //icons showing interactive features of individual
  void showInteractiveNodeInfo(HashMap <String, Integer> nodeInfo){
    int iconSize = 14;
    int currentX = iconSize;
    fill(colors.get("primary"));
    noStroke();
    
    if(nodeInfo.containsKey("aud") || nodeInfo.containsKey("auh") || nodeInfo.containsKey("aul")){
      showInteractiveIcon(musicIcon, currentX, iconSize, iconSize);
      currentX += iconSize * 2;
    }
    if(nodeInfo.containsKey("bri")){
      showInteractiveIcon(videoIcon, currentX, iconSize, iconSize);
      currentX += iconSize * 2;
    }
    if(nodeInfo.containsKey("var")){
      showInteractiveIcon(dataIcon, currentX, iconSize, iconSize);
      currentX += iconSize * 2;
    }
  }
  
  void showInteractiveIcon(PShape _icon, float _x, float _y, float _s){
    fill(colors.get("primary"));
    shape(_icon, _x, _y, _s, _s);
  }
}

//buttons on hovering individual
class IndividualHover {

  float w, h;
  float gridW, gridH, shiftX, shiftY;
  IconButton eye, download, minus, plus;

  IndividualHover(float _indivSide, float _aspectRatio) {

    if (_aspectRatio > 1) {
      gridH = _indivSide/aspectRatio;
      gridW = _indivSide;
    } else {
      gridW = _indivSide*aspectRatio;
      gridH = _indivSide;
    }

    w = gridW;

    int buttonW = 40;
    float buttonGap = (w - (buttonW * 4)) / 5;

    eye = new IconButton(buttonGap - w/2, gap/2, buttonW, "eye");
    download = new IconButton(buttonGap*2 + buttonW - w/2, gap/2, buttonW, "download");
    minus = new IconButton(buttonGap*3 + buttonW*2 - w/2, gap/2, buttonW, "minus");
    plus = new IconButton(buttonGap*4 + buttonW*3 - w/2, gap/2, buttonW, "plus");

    h = buttonW + gap;
  }

  void show() {
    pushMatrix();
    translate(0, gridH - h);
    noStroke();
    fill(colors.get("surface"));
    rect(-w/2, 0, w, h);

    eye.show();
    download.show();
    minus.show();
    plus.show();
    
    popMatrix();
  }
  
  void showTypeIcons(){
    fill(colors.get("surface"));
    noStroke();
    
    int iconSize = 12;
    
    fill(colors.get("primary"));
    
    shape(icons.get("music"), gridW - iconSize * 2, iconSize/2, iconSize, iconSize);
    shape(icons.get("video"), gridW - iconSize * 4.5, iconSize/2, iconSize, iconSize);
    shape(icons.get("data"), gridW - iconSize * 6.5, iconSize/2, iconSize, iconSize);
  }
  
  void setValues(float _gridW, float _gridH, float _shiftX, float _shiftY){
    gridW = _gridW;
    gridH = _gridH;
    shiftX = _shiftX;
    shiftY = _shiftY;
  }


  boolean checkEye() {
    return eye.getSelected();
  }

  boolean checkDownload() {
    return download.getSelected();
  }

  boolean checkMinus() {
    return minus.getSelected();
  }

  boolean checkPlus() {
    return plus.getSelected();
  }
}
