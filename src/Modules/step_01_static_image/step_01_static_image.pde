/*
STEP 01 - STATIC IMAGE

Produces a random static output.
Press mouse to randomize again.
*/

Individual individual;
int maxDepth = 25;
String[] fragShaderTemplateLines;
int shaderChangeLineStart;
Operation[] enabledOperations;

void setup() {
  size(940,940,P2D);
  
  //load template shader
  fragShaderTemplateLines = loadStrings("fragShaderTemplate.glsl");
  
  //find line in the template that is to be changed
  shaderChangeLineStart = findLineToChangeInShader(fragShaderTemplateLines);
  
  //create array of operations i.e. function set
  enabledOperations = setupOperations();
  
  //create an individual
  individual = new Individual();
}

void draw() {
  //show individual
  drawPhenotype(0, 0, width, height, individual.getShader());
}

void mouseReleased() {
  //create individual
  individual = new Individual();
}
