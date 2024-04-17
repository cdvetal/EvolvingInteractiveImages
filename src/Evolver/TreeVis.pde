class TreeVis {

  Individual individual;
  PVector treeDimensions;
  int cellSize;
  Node[][] nodeGrid;
  String directory;

  TreeVis(Individual _individual) {
    individual = _individual;
    treeDimensions = individual.getVisDimensions();

    directory = sketchPath("shaders/tree/");

    println(treeDimensions.x + " _ " + treeDimensions.y);
    nodeGrid = new Node[int(treeDimensions.x)][int(treeDimensions.y)];

    cellSize = floor(min(width/treeDimensions.x, height/treeDimensions.y));

    setupNodes();
  }

  void setDimensions(float _w, float _y) {
    cellSize = floor(min(_w/treeDimensions.x, _y/treeDimensions.y));
  }

  void setupNodes() {
    for (int i = 0; i < individual.getNChildNodes(); i++) {
      Node node = individual.tree.getNode(i);
      if (node == null) continue;
      PVector nodeLocation = node.getVisLocation();
      int x = floor(nodeLocation.x), y = floor(nodeLocation.y);
      String shaderName = doShaderName(x, y);
      exportTreeShader(node, shaderName);
      nodeGrid[x][y] = node.getCopy(); //out of bounds x - 3; y - 0
    }
  }

  void showTree() {
    for (int i = 0; i < nodeGrid.length; i ++) {
      for (int j = 0; j < nodeGrid[nodeGrid.length-1].length; j++) {
        if (nodeGrid[i][j] != null) {
          float x = (i + 0.1) * cellSize;
          float y = (j + 0.1) * cellSize;
          float side = cellSize * 0.8;

          PImage img = getCellImage(i, j, side, side);

          if (img != null) {
            image(img, x, y, side, side);
          } else {
            fill(colors.get("surface"));
            noStroke();
            rect(x, y, side, side);
          }


          if (j > 0) {
            float parentCenterX = 0;
            float parentCenterY = 0;

            int parentJ = j - 1;
            for (int parentI = i; parentI > -1; parentI--) {
              if (nodeGrid[parentI][parentJ] != null) {
                parentCenterX = (parentI + 0.5) * cellSize;
                parentCenterY = (parentJ + 0.5) * cellSize;
                break;
              }
            }

            float centerX = (i + 0.5) * cellSize;
            float centerY = (j + 0.5) * cellSize;

            stroke(colors.get("primary"));
            strokeWeight(2);

            line(centerX, centerY, parentCenterX, parentCenterY);
          }
        }
      }
    }
  }

  String doShaderName(int _a, int _b) {
    return _a + "_" + _b;
  }

  PImage getCellImage(int _a, int _b, float _w, float _h) {

    String shaderName = doShaderName(_a, _b);
    String shaderPath = directory + shaderName + ".glsl";

    File shaderFile = dataFile(shaderPath);
    if (shaderFile.exists()) {

      PShader shader = loadShader(shaderPath);

      return getPhenotype(_w, _h, shader, getExternalValue(), getAudioSpectrum());
    } else {
      return null;
    }
  }
}
