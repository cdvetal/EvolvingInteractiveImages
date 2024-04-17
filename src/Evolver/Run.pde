class Run {

  String UUID;
  JSONObject json;
  JSONArray populationsJSON;

  String currentPopulationID;

  void startRun() {
    UUID = generateUUID();
    populationsJSON = new JSONArray();

    json = new JSONObject();

    json.setString("id", UUID);
    json.setString("timestamp", year() + "-" + nf(month(),2) + "-" + nf(day(),2) + "-" + nf(hour(),2) + "-" + nf(minute(),2) + "-" + nf(second(),2));

    json.setJSONObject("parameters", getParameters());
  }

  void startRun(JSONObject _runJSON) {
    json = _runJSON;

    UUID = json.getString("id");

    setParameters(json.getJSONObject("parameters"));

    JSONArray populations = json.getJSONArray("populations");

    int highestGeneration = 0;
    JSONObject highestGenPopulation = populations.getJSONObject(0);

    for (int i = 1; i < populations.size(); i++) {
      JSONObject population = populations.getJSONObject(i);
      int generation = population.getInt("generation");
      if (generation > highestGeneration) {
        highestGeneration = generation;
        highestGenPopulation = population;
      }
    }
    
    currentPopulationID = highestGenPopulation.getString("id");
    Individual[] individuals = loadIndividuals(highestGenPopulation.getJSONArray("individuals"));
    
    population = new Population(individuals, highestGeneration);
  }

  void updateRunJSON() {
    JSONObject toExportJSON = json;

    toExportJSON.setJSONArray("populations", populationsJSON);

    saveJSONObject(toExportJSON, getRunPath() + UUID+ ".json");
  }

  void evolved(int _generation, Individual[] _individuals) {
    JSONObject populationJSON = new JSONObject();

    String previousPopulationID = currentPopulationID;
    currentPopulationID = generateUUID();

    populationJSON.setString("timestamp", hour() + "h:" + minute() + "m:" + second() + "s");
    populationJSON.setInt("generation", _generation);
    populationJSON.setString("ascendantID", previousPopulationID);
    populationJSON.setString("id", currentPopulationID);

    JSONArray individualsJSON = new JSONArray();

    for (int i = 0; i < _individuals.length; i++) {
      JSONObject individualJSON = new JSONObject();

      String[] individualExpressions = _individuals[i].tree.getExpressions();
      JSONObject expressionsJSON = new JSONObject();

      expressionsJSON.setString("r", individualExpressions[0]);
      expressionsJSON.setString("b", individualExpressions[1]);
      expressionsJSON.setString("g", individualExpressions[2]);

      individualJSON.setJSONObject("expressions", expressionsJSON);

      individualJSON.setFloat("fitness", _individuals[i].fitness);

      individualsJSON.setJSONObject(i, individualJSON);
    }

    populationJSON.setJSONArray("individuals", individualsJSON);
    populationsJSON.setJSONObject(populationsJSON.size(), populationJSON);

    updateRunJSON();
  }

  void loadPrevious() {
    //find population with currentPopulationID
    //load its ascendantPopulation
  }

  void loadNext() {
    //find latest with ascendant = currentPopulationID
  }

  JSONObject getParameters() {
    JSONObject parametersJSON = new JSONObject();

    parametersJSON.setInt("populationSize", populationSize);
    parametersJSON.setFloat("eliteSize", eliteSize);
    parametersJSON.setInt("tournamentSize", tournamentSize);
    parametersJSON.setFloat("crossoverRate", crossoverRate);
    parametersJSON.setFloat("mutationRate", mutationRate);

    return parametersJSON;
  }

  String getRunPath() {
    return sketchPath("runs/");
  }

  void setParameters(JSONObject _parameters) {
    populationSize = _parameters.getInt("populationSize");
    eliteSize = _parameters.getInt("eliteSize");
    tournamentSize = _parameters.getInt("tournamentSize");
    crossoverRate = _parameters.getFloat("crossoverRate");
    mutationRate = _parameters.getFloat("mutationRate");
  }
  
  Individual[] loadIndividuals(JSONArray _individuals){
    Individual[] individualsToReturn = new Individual[_individuals.size()];
    
    for(int i = 0; i < individualsToReturn.length; i++){
      JSONObject individualJSON = _individuals.getJSONObject(i);
      
      JSONObject expressionsJSON = individualJSON.getJSONObject("expressions");
      String[] expressions = new String[3];
      expressions[0] = expressionsJSON.getString("r");
      expressions[1] = expressionsJSON.getString("g");
      expressions[2] = expressionsJSON.getString("b");
      
      float fitness = individualJSON.getFloat("fitness");
      
      //individualsToReturn[i] = new Individual(expressions, fitness);
    }
    
    return individualsToReturn;
  }
  
  int getHighestGenerationInRun(JSONObject _run){
    JSONArray populations = _run.getJSONArray("populations");

    int highestGeneration = 0;

    for (int i = 1; i < populations.size(); i++) {
      JSONObject population = populations.getJSONObject(i);
      int generation = population.getInt("generation");
      if (generation > highestGeneration) {
        highestGeneration = generation;
      }
    }
    
    return highestGeneration;
  }
}
