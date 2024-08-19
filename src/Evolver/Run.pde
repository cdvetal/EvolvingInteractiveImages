/*

 Handles the information of each evolutionary run.
 Information is stored in a json.
 
 */

class Run {

  String UUID;
  JSONObject json;
  JSONArray populationsJSON;

  String previousPopulationID;
  String currentPopulationID;

  void startRun() {
    UUID = generateUUID();
    populationsJSON = new JSONArray();

    json = new JSONObject();

    json.setString("id", UUID);
    json.setString("timestamp", year() + "-" + nf(month(), 2) + "-" + nf(day(), 2) + "-" + nf(hour(), 2) + "-" + nf(minute(), 2) + "-" + nf(second(), 2));

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
    
    loadPopulation(highestGenPopulation, true);
  }

  void updateRunJSON() {
    JSONObject toExportJSON = json;

    toExportJSON.setJSONArray("populations", populationsJSON);

    saveJSONObject(toExportJSON, getRunPath() + UUID+ ".json");
  }

  //evolved is ran at the beginning of evolution process and at the end @ population.evolve(). At the beginning it replaces population (false), at the end it creates new one (true)
  void evolved(int _generation, Individual[] _individuals, boolean _newPopulation) {
    JSONObject populationJSON = new JSONObject();

    if (_newPopulation) {
      previousPopulationID = currentPopulationID;
      currentPopulationID = generateUUID();
    }

    populationJSON.setString("timestamp", hour() + "h:" + minute() + "m:" + second() + "s");
    populationJSON.setInt("generation", _generation);
    populationJSON.setString("ascendantID", previousPopulationID);
    populationJSON.setString("id", currentPopulationID);

    JSONArray individualsJSON = new JSONArray();

    for (int i = 0; i < _individuals.length; i++) {
      JSONObject individualJSON = new JSONObject();

      String individualExpression = _individuals[i].tree.getFunctionString();

      individualJSON.setString("expression", individualExpression);

      individualJSON.setFloat("fitness", _individuals[i].fitness);

      individualsJSON.setJSONObject(i, individualJSON);
    }

    populationJSON.setJSONArray("individuals", individualsJSON);

    //replace existing population
    if (!_newPopulation) {
      for (int i = 0; i < populationsJSON.size(); i++) {
        JSONObject currentPopulation = populationsJSON.getJSONObject(i);
        if (currentPopulation.getString("id").equals(currentPopulationID)) {
          populationsJSON.setJSONObject(i, populationJSON);
        }
      }
      //add population
    } else {
      populationsJSON.setJSONObject(populationsJSON.size(), populationJSON);
    }

    updateRunJSON();
  }

  void loadPrevious() {
    //find population with currentPopulationID
    int currentGeneration = population.nGenerations;

    //already in first generation
    if (currentGeneration == 0) {
      popup.setPopup("There are no previous Generations");
      return;
    }

    String ascendantID = "";

    for (int i = 0; i < populationsJSON.size(); i++) {
      JSONObject population = populationsJSON.getJSONObject(i);

      if (population.getString("id") == currentPopulationID) {
        ascendantID = population.getString("ascendantID");
      }
    }

    //previous generation not found
    if (ascendantID == "") {
      popup.setPopup("Previous Generation not found");
      return;
    }

    //load its ascendantPopulation
    for (int i = 0; i < populationsJSON.size(); i++) {
      JSONObject population = populationsJSON.getJSONObject(i);

      if (population.getString("id").equals(ascendantID)) {
        loadPopulation(population, false);
        return;
      }
    }
  }

  void loadNext() {
    //find latest with ascendant = currentPopulationID
    for (int i = 0; i < populationsJSON.size(); i++) {
      JSONObject population = populationsJSON.getJSONObject(i);

      if (population.getString("ascendantID") == currentPopulationID) {
        loadPopulation(population, false);
        return;
      }
    }
    
    //not found
    popup.setPopup("Next Generation not found");
    
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
  
  void loadPopulation(JSONObject _population, Boolean _allOperations){
    
    currentPopulationID = _population.getString("id");
    if(_population.hasKey("ascendantID")){
      previousPopulationID = _population.getString("ascendantID");
    } else {
      previousPopulationID = "";
    }
    
    Individual[] individuals = loadIndividuals(_population.getJSONArray("individuals"), _allOperations);

    population = new Population(individuals, _population.getInt("generation"));
    
    populationScreen.setPopulation(population);
  }

  Individual[] loadIndividuals(JSONArray _individuals, Boolean _allOperations) {
    Individual[] individualsToReturn = new Individual[_individuals.size()];

    for (int i = 0; i < individualsToReturn.length; i++) {
      JSONObject individualJSON = _individuals.getJSONObject(i);

      String expression = individualJSON.getString("expression");

      float fitness = individualJSON.getFloat("fitness");

      individualsToReturn[i] = new Individual(expression, fitness, _allOperations);
    }

    return individualsToReturn;
  }

  int getHighestGenerationInRun(JSONObject _run) {
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
