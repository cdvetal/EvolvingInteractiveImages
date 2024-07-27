/*

Handles the visualization of the trees.

*/

class TreeVis { //needs fixing

  Individual individual;
  PVector treeDimensions;
  int cellSize;
  Node[][] nodeGrid;
  String directory;

  TreeVis(Individual _individual) {
    directory = sketchPath("shaders/tree/");

    clearTreeShaderFiles();

    individual = _individual;
    individual.cleanUp();
    treeDimensions = individual.getVisDimensions();

    nodeGrid = new Node[int(treeDimensions.x)][int(treeDimensions.y)];

    cellSize = floor(min(width/treeDimensions.x, height/treeDimensions.y));

    setupNodes();
  }

  void setDimensions(float _w, float _y) {
    cellSize = floor(min(_w/treeDimensions.x, _y/treeDimensions.y));
  }

  void setupNodes() {
    for (int i = 0; i < individual.getNChildNodes() + 1; i++) {
      Node node = individual.tree.getNode(i);
      if (node == null) continue;
      PVector nodeLocation = node.getVisLocation();
      int x = floor(nodeLocation.x), y = floor(nodeLocation.y);

      if (x >= nodeGrid.length) {//out of bounds temporary fix
        println("TreeVis out of bounds x");
        break;
      }

      String shaderName = doShaderName(x, y);
      exportTreeShader(node, shaderName);
      nodeGrid[x][y] = node.getCopy(); //out of bounds x - 3; y - 0
    }
  }

  void showTree(boolean _showOperation) {
    textAlign(CENTER, CENTER);
    textFont(fonts.get("light"));
    textSize(12);

    //lines
    for (int i = 0; i < nodeGrid.length; i ++) { //x
      for (int j = 0; j < nodeGrid[nodeGrid.length-1].length; j++) { //y
        if (nodeGrid[i][j] != null) {
          if (j > 0) {
            int thisIndex = nodeGrid[i][j].nodeIndex;
            float centerX = (i + 0.5) * cellSize;
            float centerY = (j + 0.5) * cellSize;
            float parentCenterX = centerX;
            float parentCenterY = centerY;

            //look for parent to connect
          iLoop:
            for (int parentI = i; parentI > -1; parentI --) {
              for (int parentJ = j; parentJ > -1; parentJ --) {
                if (nodeGrid[parentI][parentJ] == null) { //potential parent node exists
                  continue;
                }

                if (nodeGrid[parentI][parentJ].isTerminal()) { //potential parent has children
                  continue;
                }

                for (int k = 0; k < nodeGrid[parentI][parentJ].childrenNodes.length; k ++) {//check if children ID == this node ID
                  if (nodeGrid[parentI][parentJ].childrenNodes[k].nodeIndex == thisIndex) {
                    parentCenterX = (parentI + 0.5) * cellSize;
                    parentCenterY = (parentJ + 0.5) * cellSize;
                    break iLoop;
                  }
                }
              }
            }

            stroke(colors.get("primary"));
            strokeWeight(2);

            line(centerX, centerY, parentCenterX, parentCenterY);
          }
        }
      }
    }

    float[] variables = variablesManager.getShaderReadyVariables();
    float[] audioSpectrum = getAudioSpectrum();

    //cells
    for (int i = 0; i < nodeGrid.length; i ++) {
      for (int j = 0; j < nodeGrid[nodeGrid.length-1].length; j++) {
        if (nodeGrid[i][j] != null) {
          float x = (i + 0.1) * cellSize;
          float y = (j + 0.1) * cellSize;
          float side = cellSize * 0.8;

          PShader currentShader = getCellShader(i, j);

          if (currentShader != null) {
            drawPhenotype(x, y, side, side, currentShader, variables, audioSpectrum);
          } else {
            fill(colors.get("surface"));
            noStroke();
            rect(x, y, side, side);
          }

          if (_showOperation) {
            noStroke();
            fill(colors.get("surface"));
            rect(x, y+side-gap, side, gap);
            fill(colors.get("primary"));
            text(nodeGrid[i][j].getNodeText(), x + side/2, y + side - gap + gap/2);
            //text("i: " + i + "_ j: " + j, x + side/2, y + side - gap + gap/2);
          }
        }
      }
    }
  }

  String doShaderName(int _a, int _b) {
    return _a + "_" + _b;
  }

  PShader getCellShader(int _a, int _b) {
    String shaderName = doShaderName(_a, _b);
    String shaderPath = directory + shaderName + ".glsl";

    File shaderFile = dataFile(shaderPath);
    if (shaderFile.exists()) {

      PShader shader = loadShader(shaderPath, "vertShaderTemplate.glsl");

      return shader;
    }

    return null;
  }

  PImage getCellImage(int _a, int _b, float _w, float _h) {

    String shaderName = doShaderName(_a, _b);
    String shaderPath = directory + shaderName + ".glsl";

    File shaderFile = dataFile(shaderPath);
    if (shaderFile.exists()) {

      PShader shader = loadShader(shaderPath, "vertShaderTemplate.glsl");

      return getPhenotype(_w, _h, shader, variablesManager.getShaderReadyVariables(), getAudioSpectrum());
    } else {
      return null;
    }
  }

  boolean detectHover(float _x, float _y) {
    if (mouseX < screenX(_x, 0))return false; //screenX and screenY because of matrix transformations
    if (mouseX > screenX(_x + cellSize, 0))return false;
    if (mouseY < screenY(0, _y)) return false;
    if (mouseY > screenY(0, _y + cellSize)) return false;

    return true;
  }

  void clearTreeShaderFiles() {
    File files = dataFile(directory);
    String[] fileNames = files.list();

    if (fileNames ==  null) return;

    for (int i = 0; i < fileNames.length; i ++) {
      File f = new File(directory + fileNames[i]);
      if (f.exists() && !fileNames[i].equals(".gitignore.txt")) {
        f.delete();
      }
    }
  }
}
