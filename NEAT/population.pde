// Population class for NEAT algorithm
class Population {
    
    ArrayList<Dino> dinos = new ArrayList<Dino>();
    ArrayList<Genotype> genotypes = new ArrayList<Genotype>();
    
    ObstacleManager obstacleManager = new ObstacleManager();
    
    int populationSize = 50; // Increased from 20 to 50
    int generation = 1;
    int aliveCount = 0;
    boolean allDead = false;
    
    float bestFitness = 0;
    float averageFitness = 0;
    float bestNormalFitness = 0;  // Best actual game score (for display)
    float averageNormalFitness = 0;  // Average actual game score (for display)
    
    // Performance tracking
    ArrayList<Float> generationBestScores = new ArrayList<Float>();
    ArrayList<Float> generationAvgScores = new ArrayList<Float>();
    
    Population() {
        // Create initial population
        for (int i = 0; i < populationSize; i++) {
            Genotype genotype = new Genotype(8, 2); // 8 inputs, 2 outputs (jump, duck)
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
        float totalNormalFitness = 0;
        bestFitness = 0;
        bestNormalFitness = 0;
        
        for (int i = 0; i < dinos.size(); i++) {
            float fitness = dinos.get(i).calculateFitness();
            float normalFitness = dinos.get(i).score;  // Just the game score
            
            genotypes.get(i).fitness = fitness;
            totalFitness += fitness;
            totalNormalFitness += normalFitness;
            
            if (fitness > bestFitness) {
                bestFitness = fitness;
            }
            
            if (normalFitness > bestNormalFitness) {
                bestNormalFitness = normalFitness;
            }
        }
        
        averageFitness = totalFitness / populationSize;
        averageNormalFitness = totalNormalFitness / populationSize;
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
        
        int eliteCount = populationSize / 5; // Top 20% instead of 10%
        for (int i = 0; i < eliteCount; i++) {
            newGenotypes.add(new Genotype(sorted.get(i)));
        }
        
        // Fill rest with offspring
        while (newGenotypes.size() < populationSize) {
            Genotype parent1 = selectParent();
            Genotype parent2 = selectParent();
            
            Genotype offspring;
            if (random(1) < 0.80) { // 80% crossover, 20% mutation only (increased from 75%)
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
        
        // Track performance
        generationBestScores.add(bestNormalFitness);
        generationAvgScores.add(averageNormalFitness);
        
        println("Generation " + generation + " - Best: " + bestNormalFitness + " Avg: " + averageNormalFitness);
        
        // Print performance trend every 5 generations
        if (generation % 5 == 0) {
            printPerformanceTrend();
        }
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
               " Best: " + nf(bestNormalFitness, 1, 1) + " Avg: " + nf(averageNormalFitness, 1, 1);
    }
    
    // Print performance trend analysis
    void printPerformanceTrend() {
        if (generationBestScores.size() < 5) return;
        
        int recentGens = min(5, generationBestScores.size());
        float recentAvgBest = 0;
        float recentAvgAvg = 0;
        
        for (int i = generationBestScores.size() - recentGens; i < generationBestScores.size(); i++) {
            recentAvgBest += generationBestScores.get(i);
            recentAvgAvg += generationAvgScores.get(i);
        }
        
        recentAvgBest /= recentGens;
        recentAvgAvg /= recentGens;
        
        println("--- Performance Trend (last " + recentGens + " generations) ---");
        println("Average Best Score: " + nf(recentAvgBest, 1, 1));
        println("Average Population Score: " + nf(recentAvgAvg, 1, 1));
        
        if (generationBestScores.size() >= 10) {
            float oldAvgBest = 0;
            for (int i = generationBestScores.size() - 10; i < generationBestScores.size() - 5; i++) {
                oldAvgBest += generationBestScores.get(i);
            }
            oldAvgBest /= 5;
            
            float improvement = ((recentAvgBest - oldAvgBest) / max(1, oldAvgBest)) * 100;
            println("Improvement over last 5 gens: " + nf(improvement, 1, 1) + "%");
        }
        
        println("-----------------------------------------------");
    }
}