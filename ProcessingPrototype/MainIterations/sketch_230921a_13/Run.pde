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
    json.setString("timestamp", year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second());

    json.setJSONObject("parameters", getParameters());
  }

  void updateRunJSON() {
    JSONObject toExportJSON = json;

    toExportJSON.setJSONArray("populations", populationsJSON);

    saveJSONObject(toExportJSON, "runs/" + UUID+ ".json");
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

      String[] individualExpressions = _individuals[i].getExpressions();
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
}
