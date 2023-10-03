class Population {
  
  Individual[] individuals;
  int nGenerations;

  Population() {
    individuals = new Individual[populationSize];
    initialize();
  }

  void initialize() {
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = new Individual();
      individuals[i].setFitness(0);
      individuals[i].identifyNodes();
    }

    nGenerations = 0;
  }

  void evolve() {
    Individual[] newGeneration = new Individual[individuals.length];

    sortIndividualsByFitness();
    
    for(int i = 0; i < eliteSize; i++){
      newGeneration[i] = individuals[i].getCopy();
    }
    
    for (int i = eliteSize; i < newGeneration.length; i++) {
      if (random(1) <= 0) {//crossoverRate
        Individual parent1 = tournamentSelection();
        Individual parent2 = tournamentSelection();
        Individual child = parent1.crossover(parent2);
        newGeneration[i] = child;
      } else {
        newGeneration[i] = tournamentSelection().getCopy();
      }
    }
    
    for(int i = eliteSize; i < individuals.length; i++){
      newGeneration[i].identifyNodes();
      newGeneration[i].mutate();
    }
    
    for (int i = 0; i < individuals.length; i++) {
      individuals[i] = newGeneration[i];
      individuals[i].setFitness(0);
      individuals[i].identifyNodes();
    }
    
    println("GENERATION: " + nGenerations);
    nGenerations++;
  }
  
  Individual tournamentSelection(){
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
  
  Individual getIndividual(int i){
    return individuals[i];
  }
  
  int getSize(){
    return individuals.length;
  }
}
