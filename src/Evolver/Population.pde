/*

Handles the group of individuals in the evolution.

*/

class Population {

  Individual[] individuals;
  int nGenerations;


  Population() {
    individuals = new Individual[populationSize];
  }

  Population(Individual[] _individuals, int _nGenerations) {
    individuals = _individuals;
    for(int i = 0; i < individuals.length; i++){
      individuals[i].doShader(i);
      individuals[i].identifyNodes();
    }
    nGenerations = _nGenerations;
    //sortIndividualsByFitness();
    println("LOADED POPULATION AT GENERATION: " + nGenerations);
  }

  void initialize() {
    println(maxTreeDepth);
    
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new Individual();
      individuals[i].setFitness(0);
      individuals[i].identifyNodes();
      individuals[i].doShader(i);
    }

    nGenerations = 0;
    run.evolved(nGenerations, individuals, true);
  }

  void evolve() {
    run.evolved(nGenerations, individuals, false);
        
    Individual[] newGeneration = new Individual[individuals.length];

    sortIndividualsByFitness();
    
    //add elite to new population
    for (int i = 0; i < eliteSize; i++) {
      newGeneration[i] = individuals[i].getCopy();
    }

    //do crossover
    for (int i = eliteSize; i < newGeneration.length; i++) {
      if (random(1) <= crossoverRate) {//crossoverRate
        Individual parent1 = tournamentSelection();
        Individual parent2 = tournamentSelection();
        Individual child = parent1.crossover(parent2);
        newGeneration[i] = child;
      } else {
        newGeneration[i] = tournamentSelection().getCopy();
      }
    }

    //do mutation
    for (int i = eliteSize; i < individuals.length; i++) {
      newGeneration[i].identifyNodes();
      newGeneration[i].mutate();
    }

    //finish new population
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = newGeneration[i];
      individuals[i].setFitness(0);
      individuals[i].cleanUp();
      individuals[i].doShader(i);
    }

    nGenerations++;
    run.evolved(nGenerations, individuals, true);
    popup.setPopup("Evolved to Generation " + (nGenerations));
  }

  Individual tournamentSelection() {
    Individual[] tournament = new Individual[tournamentSize];

    for (int i = 0; i < tournament.length; i++) {
      int random_index = int(random(0, individuals.length));
      tournament[i] = individuals[random_index];
    }

    Individual fittest = tournament[0];
    for (int i = 1; i < tournament.length; i++) {
      if (tournament[i].getFitness() > fittest.getFitness()) {
        fittest = tournament[i];
      }
    }

    return fittest.getCopy();
  }

  void sortIndividualsByFitness() {
    Arrays.sort(individuals, new Comparator<Individual>() {
      public int compare(Individual indiv1, Individual indiv2) {
        return Float.compare(indiv2.getFitness(), indiv1.getFitness());
      }
    }
    );
  }

  void previousPopulation() {
  }

  void nextPopulation() {
  }

  void loadPopulation() {
  }

  Individual getIndividual(int i) {
    return individuals[i];
  }

  int getSize() {
    return individuals.length;
  }
}
