// Population class for NEAT algorithm
class Population {
    
    ArrayList<Dino> dinos = new ArrayList<Dino>();
    ArrayList<Genotype> genotypes = new ArrayList<Genotype>();
    
    ObstacleManager obstacleManager = new ObstacleManager();
    
    int populationSize = 20;
    int generation = 1;
    int aliveCount = 0;
    boolean allDead = false;
    
    float bestFitness = 0;
    float averageFitness = 0;
    
    Population() {
        // Create initial population
        for (int i = 0; i < populationSize; i++) {
            Genotype genotype = new Genotype(4, 2); // 4 inputs, 2 outputs (jump, duck)
            genotypes.add(genotype);
            
            Dino dino = new Dino(genotype);
            dinos.add(dino);
        }
        
        aliveCount = populationSize;
    }
    
    // Update all dinos in the population
    void update() {
        aliveCount = 0;
        
        // Update obstacles first
        obstacleManager.update();
        
        for (int i = 0; i < dinos.size(); i++) {
            if (!dinos.get(i).isDead()) {
                dinos.get(i).think(obstacleManager); // AI decision making with obstacle data
                dinos.get(i).move();
                
                // Check collision with shared obstacles
                if (obstacleManager.checkCollision(dinos.get(i).dinoX, dinos.get(i).posY, dinos.get(i).isCrouching)) {
                    dinos.get(i).dinoDead = true;
                }
                
                if (!dinos.get(i).isDead()) {
                    aliveCount++;
                }
            }
        }
        
        // Check if all dinos are dead
        if (aliveCount == 0) {
            allDead = true;
        }
    }
    
    // Display all dinos and obstacles
    void show() {
        // Show obstacles first
        obstacleManager.show();
        
        // Show living dinos
        for (Dino dino : dinos) {
            if (!dino.isDead()) {
                dino.show();
            }
        }
    }
    
    // Calculate fitness for all genotypes
    void calculateFitness() {
        float totalFitness = 0;
        bestFitness = 0;
        
        for (int i = 0; i < dinos.size(); i++) {
            float fitness = dinos.get(i).calculateFitness();
            genotypes.get(i).fitness = fitness;
            totalFitness += fitness;
            
            if (fitness > bestFitness) {
                bestFitness = fitness;
            }
        }
        
        averageFitness = totalFitness / populationSize;
    }
    
    // Create next generation using NEAT algorithm
    void evolve() {
        calculateFitness();
        
        ArrayList<Genotype> newGenotypes = new ArrayList<Genotype>();
        
        // Keep best performers (elitism)
        ArrayList<Genotype> sorted = new ArrayList<Genotype>(genotypes);
        // Simple bubble sort by fitness (descending)
        for (int i = 0; i < sorted.size() - 1; i++) {
            for (int j = i + 1; j < sorted.size(); j++) {
                if (sorted.get(i).fitness < sorted.get(j).fitness) {
                    Genotype temp = sorted.get(i);
                    sorted.set(i, sorted.get(j));
                    sorted.set(j, temp);
                }
            }
        }
        
        int eliteCount = populationSize / 10; // Top 10%
        for (int i = 0; i < eliteCount; i++) {
            newGenotypes.add(new Genotype(sorted.get(i)));
        }
        
        // Fill rest with offspring
        while (newGenotypes.size() < populationSize) {
            Genotype parent1 = selectParent();
            Genotype parent2 = selectParent();
            
            Genotype offspring;
            if (random(1) < 0.75) { // 75% crossover, 25% mutation only
                offspring = crossover(parent1, parent2);
            } else {
                offspring = new Genotype(parent1);
            }
            
            offspring.mutate();
            newGenotypes.add(offspring);
        }
        
        // Create new dinos with new genotypes
        dinos.clear();
        genotypes = newGenotypes;
        
        for (Genotype genotype : genotypes) {
            dinos.add(new Dino(genotype));
        }
        
        // Reset environment for new generation
        obstacleManager.reset();
        
        generation++;
        aliveCount = populationSize;
        allDead = false;
        
        println("Generation " + generation + " - Best: " + bestFitness + " Avg: " + averageFitness);
    }
    
    // Select parent using tournament selection
    Genotype selectParent() {
        int tournamentSize = 5;
        Genotype best = genotypes.get((int)random(genotypes.size()));
        
        for (int i = 1; i < tournamentSize; i++) {
            Genotype competitor = genotypes.get((int)random(genotypes.size()));
            if (competitor.fitness > best.fitness) {
                best = competitor;
            }
        }
        
        return best;
    }
    
    // Crossover two genotypes to create offspring
    Genotype crossover(Genotype parent1, Genotype parent2) {
        Genotype offspring = new Genotype(parent1);
        
        // Simple crossover: randomly select connections from both parents
        for (int i = 0; i < offspring.connections.size() && i < parent2.connections.size(); i++) {
            if (random(1) < 0.5) {
                offspring.connections.get(i).m_weight = parent2.connections.get(i).m_weight;
            }
        }
        
        return offspring;
    }
    
    // Check if evolution should happen
    boolean shouldEvolve() {
        return allDead;
    }
    
    // Get statistics string
    String getStats() {
        return "Gen: " + generation + " Alive: " + aliveCount + "/" + populationSize + 
               " Best: " + nf(bestFitness, 1, 1) + " Avg: " + nf(averageFitness, 1, 1);
    }
}