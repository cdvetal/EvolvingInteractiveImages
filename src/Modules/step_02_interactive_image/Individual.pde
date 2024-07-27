/*

Handles the representation and manipulation of individuals.
It includes:
- Writting and applying shaders

*/

class Individual {

  private Node tree;
  PShader shader;

  Individual() {
    tree = new Node(0);
    tree.randomizeNode(true);
    doShader();
  }

  //creates and reads shader file
  void doShader() {
    String [] shaderLines = getShaderTextLines(tree);

    String shaderPath = sketchPath("shaders\\shader.glsl");

    saveStrings(shaderPath, shaderLines);

    shader = loadShader(shaderPath, "vertShaderTemplate.glsl");
  }


  PShader getShader() {
    return shader;
  }
}
