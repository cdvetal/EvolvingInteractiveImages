class PopulationScreen {

  float x, y, w, h;
  PVector[][] individualsGrid;
  Population pop;

  IndividualHover individualHover;

  PopulationScreen(Population _population) {
    setPopulation(_population);
  }

  void setPopulation(Population _population) {
    pop = _population;
    x = columns[2].x;
    y = border;
    w = (width - border) - x;
    h = height - (border * 2);
    individualsGrid = calculateGrid(pop.getSize(), 0, 0, w, h, 0, gap, gap, false);
    individualHover = new IndividualHover(individualsGrid[0][0].z, aspectRatio);
  }


  void show() {
    if(leftTab.getBack()){
      screen = 0; 
      return;
    } else if(leftTab.getEvolve()){
       population.evolve(); 
    }
    
    setInputImage();
    float externalValue = getExternalValue();
    float[] audioSpectrum = getAudioSpectrum();

    int row = 0, col = 0;

    float gridD = individualsGrid[0][0].z, gridH = individualsGrid[0][0].z, gridW = individualsGrid[0][0].z;
    float shift;

    if (aspectRatio > 1) {
      gridH = gridD/aspectRatio;
      shift = (gridD-gridH) / 2;
    } else {
      gridW = gridD*aspectRatio;
      shift = (gridD-gridW) / 2;
    }

    pushMatrix();
    translate(x, y);

    for (int i = 0; i < population.getSize(); i++) {
      float gridX = individualsGrid[row][col].x;
      float gridY = individualsGrid[row][col].y;
      noFill();
      
      if (aspectRatio > 1) {
        image(pop.getIndividual(i).getPhenotype(gridD, gridH, externalValue, audioSpectrum), gridX, gridY + shift, gridD, gridH);
        stroke(colors.get("primary"));
        strokeWeight(4);
        line(gridX, gridY + gap/2 + gridH + shift, gridX + (gridD * pop.getIndividual(i).getFitness()), gridY + gap/2 + gridH + shift);
      } else {
        image(pop.getIndividual(i).getPhenotype(gridW, gridD, externalValue, audioSpectrum), gridX + shift, gridY, gridW, gridD);
        stroke(colors.get("primary"));
        strokeWeight(4);
        line(gridX, gridY + gap/2 + gridD, gridX + (gridD * pop.getIndividual(i).getFitness()), gridY + gap/2 + gridD);
      }

      if (mouseX > screenX(gridX, 0) && mouseX < screenX(gridX + gridD, 0) && mouseY > screenY(0, gridY) && mouseY < screenY(0, gridY + gridD)) {
        pushMatrix();

        if (aspectRatio > 1) {
          translate(gridX, gridY + gridH + shift - individualHover.h);
        } else {
          translate(gridX + shift, gridY + gridD - individualHover.h);
        }

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
          screen = 3;
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
}

class IndividualHover {

  float w, h;
  IconButton eye, download, minus, plus;

  IndividualHover(float _indivSide, float _aspectRatio) {

    float indivW, shift;

    if (_aspectRatio > 1) {
      indivW = _indivSide;
    } else {
      indivW = _indivSide*aspectRatio;
    }

    w = indivW;

    int buttonW = 40;
    float buttonGap = (w - (buttonW * 4)) / 5;


    eye = new IconButton(buttonGap, gap/2, buttonW, "eye");
    download = new IconButton(buttonGap*2 + buttonW, gap/2, buttonW, "download");
    minus = new IconButton(buttonGap*3 + buttonW*2, gap/2, buttonW, "minus");
    plus = new IconButton(buttonGap*4 + buttonW*3, gap/2, buttonW, "plus");

    h = buttonW + gap;
  }

  void show() {
    noStroke();
    fill(colors.get("surface"));
    rect(0, 0, w, h);

    eye.show();
    download.show();
    minus.show();
    plus.show();
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
