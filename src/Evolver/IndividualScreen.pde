/*

Handles the area that shows a single individual.
It includes:
- Showing phenotype
- Showing tree

*/

class IndividualScreen {

  float x, y, w, h;

  TreeVis treeVis;
  Individual individual;

  String nodeInfoString;

  IndividualScreen() {

    x = columns[2].x;
    y = border;
    w = (width - border) - x;
    h = height - (border * 2);
  }

  void show() {
    if (leftTab.getBack()) {
      individual = null;
      treeVis = null;
      screen = "population";
      return;
    } else if (leftTab.getFullscreen()){
      showFullscreen();
      return; 
    }

    Boolean[] layout = leftTab.getLayout();

    if (layout[0]) showImage(!(layout[0] == layout[1]));
    if (layout[1]) showTree(!(layout[0] == layout[1]));
  }
  
  void showFullscreen(){
    background(0);
    image(getPhenotype(width, height, individual.getShader(), variablesManager.getShaderReadyVariables(), getAudioSpectrum()), 0, 0);
  }

  void showImage(boolean _full) {
    setInputImage();
    float[] variables = variablesManager.getShaderReadyVariables();
    float[] audioSpectrum = getAudioSpectrum();

    if (_full) {
      image(getPhenotype(w, h, individual.getShader(), variables, audioSpectrum), x, y);
    } else {
      float imageW = columns[5].y - x;
      image(getPhenotype(imageW, h, individual.getShader(), variables, audioSpectrum), x, y);
    }
  }

  void showTree(boolean _full) {
    pushMatrix();

    if (_full) {
      treeVis.setDimensions(columns[columns.length-1].y - columns[2].x, height - border*2);
      translate(x, y);
    } else {
      treeVis.setDimensions(columns[columns.length-1].y - columns[6].x, height - border*2);
      translate(columns[6].x, y);
    }

    treeVis.showTree(leftTab.getTreeButtonHover());

    popMatrix();
  }

  void setIndividual(Individual _individual) {
    individual = _individual;
    treeVis = new TreeVis(individual);
    nodeInfoString = getNodeInfoString(individual.getOperationStats());
  }

  String getNodeInfoString(HashMap <String, Integer> _operationStats) {
    StringBuilder stringBuilder = new StringBuilder();

    for (Map.Entry<String, Integer> entry : _operationStats.entrySet()) {
      stringBuilder.append(entry.getKey()).append(":").append(entry.getValue()).append("; ");
    }

    return stringBuilder.toString();
  }
}
