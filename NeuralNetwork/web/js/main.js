// Main application controller
class DinoGameApp {
    constructor() {
        this.canvas = document.getElementById('gameCanvas');
        this.game = new DinoGame(this.canvas);
        this.networkViz = new NetworkVisualizer('#networkViz');
        this.evolutionStats = new EvolutionStats('#evolutionStats');
        
        this.isTraining = false;
        this.currentGeneration = 1;
        this.population = [];
        this.currentGenomeIndex = 0;
        
        this.initializeEventListeners();
        this.initializeStats();
        
        // Connect to C++ WebSocket server
        this.setupWebSocket();
    }
    
    // Initialize event listeners
    initializeEventListeners() {
        // Button controls
        document.getElementById('startBtn').addEventListener('click', () => this.startTraining());
        document.getElementById('pauseBtn').addEventListener('click', () => this.pauseTraining());
        document.getElementById('resetBtn').addEventListener('click', () => this.resetTraining());
        
        // Keyboard controls for manual play
        document.addEventListener('keydown', (e) => {
            if (!this.isTraining) {
                this.game.handleInput(e.key, true);
            }
        });
        
        document.addEventListener('keyup', (e) => {
            if (!this.isTraining) {
                this.game.handleInput(e.key, false);
            }
        });
        
        // Start manual game
        this.game.start();

        // Add this line to update stats regularly (30 times per second)
        setInterval(() => this.updateStats(), 1000/30);
    }
    
    // Initialize statistics display
    initializeStats() {
        this.updateStats();
    }
    
    // Update statistics display
    updateStats() {
        document.getElementById('score').textContent = `Score: ${this.game.score}`;
        document.getElementById('generation').textContent = `Generation: ${this.currentGeneration}`;
        document.getElementById('fitness').textContent = `Fitness: ${this.game.getFitness()}`;
    }
    
    // Start NEAT training
    startTraining() {
        if (this.isTraining) return;
        
        this.isTraining = true;
        this.game.stop();
        
        // Initialize population (placeholder - will be replaced by C++ NEAT)
        this.initializePopulation();
        
        // Start training loop
        this.trainingLoop();
        
        // Update UI
        document.getElementById('startBtn').disabled = true;
        document.getElementById('pauseBtn').disabled = false;
    }
    
    // Initialize population (placeholder)
    initializePopulation() {
        this.population = [];
        this.currentGenomeIndex = 0;
        
        // Create dummy genomes for demonstration
        for (let i = 0; i < 30; i++) {
            this.population.push({
                id: i,
                fitness: 0,
                network: this.createDummyNetwork()
            });
        }
    }
    
    // Create dummy neural network for demonstration
    createDummyNetwork() {
        return {
            numInputs: 4,
            numOutputs: 2,
            numLayers: 3,
            nodes: [
                { id: 0, layer: 0, type: 'input' },
                { id: 1, layer: 0, type: 'input' },
                { id: 2, layer: 0, type: 'input' },
                { id: 3, layer: 0, type: 'input' },
                { id: 4, layer: 1, type: 'hidden' },
                { id: 5, layer: 1, type: 'hidden' },
                { id: 6, layer: 2, type: 'output' },
                { id: 7, layer: 2, type: 'output' }
            ],
            connections: [
                { fromNode: 0, toNode: 4, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 1, toNode: 4, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 2, toNode: 4, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 3, toNode: 4, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 0, toNode: 5, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 1, toNode: 5, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 2, toNode: 5, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 3, toNode: 5, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 4, toNode: 6, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 5, toNode: 6, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 4, toNode: 7, weight: Math.random() * 2 - 1, enabled: true },
                { fromNode: 5, toNode: 7, weight: Math.random() * 2 - 1, enabled: true }
            ]
        };
    }
    
    // Main training loop
    trainingLoop() {
        if (!this.isTraining) return;
        
        // Get current genome
        const currentGenome = this.population[this.currentGenomeIndex];
        
        // Set neural network for the game
        this.game.setNeuralNetwork(currentGenome.network);
        
        // Start game for this genome
        this.game.start();
        
        // Run game until death or timeout
        this.runGenome(currentGenome);
    }
    
    // Run a single genome
    runGenome(genome) {
        const maxSteps = 5000; // Prevent infinite loops
        let steps = 0;
        
        const gameStep = () => {
            if (!this.isTraining) return;
            
            // Update AI
            this.game.updateAI();
            
            // Update game
            this.game.update();
            this.game.render();
            
            // Update visualization
            this.networkViz.updateRealTime(genome.network, [0.5, 0.3]); // Dummy outputs
            
            // Update stats
            this.updateStats();
            
            steps++;
            
            // Check if game is over or max steps reached
            if (this.game.isDead() || steps >= maxSteps) {
                // Set fitness
                genome.fitness = this.game.getFitness();
                
                // Move to next genome
                this.currentGenomeIndex++;
                
                if (this.currentGenomeIndex >= this.population.length) {
                    // Generation complete, evolve
                    this.evolve();
                } else {
                    // Continue with next genome
                    setTimeout(() => this.trainingLoop(), 100);
                }
            } else {
                // Continue game
                requestAnimationFrame(gameStep);
            }
        };
        
        gameStep();
    }
    
    // Evolve to next generation
    evolve() {
        // Sort population by fitness
        this.population.sort((a, b) => b.fitness - a.fitness);
        
        // Calculate statistics
        const bestFitness = this.population[0].fitness;
        const avgFitness = this.population.reduce((sum, g) => sum + g.fitness, 0) / this.population.length;
        
        // Update evolution chart
        this.evolutionStats.addFitness(this.currentGeneration, bestFitness, avgFitness);
        
        // Update network visualization with best genome
        this.networkViz.updateNetwork(this.population[0].network);
        
        // Create next generation (simplified evolution)
        this.createNextGeneration();
        
        // Reset for next generation
        this.currentGeneration++;
        this.currentGenomeIndex = 0;
        
        // Continue training
        setTimeout(() => this.trainingLoop(), 500);
    }
    
    // Create next generation (simplified)
    createNextGeneration() {
        const newPopulation = [];
        
        // Keep top 20%
        const eliteCount = Math.floor(this.population.length * 0.2);
        for (let i = 0; i < eliteCount; i++) {
            newPopulation.push({ ...this.population[i] });
        }
        
        // Create rest through mutation
        while (newPopulation.length < this.population.length) {
            const parent = this.population[Math.floor(Math.random() * eliteCount)];
            const child = this.mutateGenome(parent);
            newPopulation.push(child);
        }
        
        this.population = newPopulation;
    }
    
    // Mutate a genome
    mutateGenome(parent) {
        const child = JSON.parse(JSON.stringify(parent)); // Deep copy
        
        // Mutate connection weights
        child.network.connections.forEach(conn => {
            if (Math.random() < 0.1) { // 10% mutation rate
                conn.weight += (Math.random() - 0.5) * 0.2;
            }
        });
        
        child.fitness = 0;
        return child;
    }
    
    // Pause training
    pauseTraining() {
        this.isTraining = false;
        this.game.stop();
        
        document.getElementById('startBtn').disabled = false;
        document.getElementById('pauseBtn').disabled = true;
    }
    
    // Reset training
    resetTraining() {
        this.isTraining = false;
        this.currentGeneration = 1;
        this.population = [];
        this.currentGenomeIndex = 0;
        
        this.game.stop();
        this.game.start();
        
        this.networkViz.clear();
        this.evolutionStats.clear();
        
        document.getElementById('startBtn').disabled = false;
        document.getElementById('pauseBtn').disabled = true;
        
        this.updateStats();
    }
    
    // Handle WebSocket communication with C++ backend
    setupWebSocket() {
        this.ws = new WebSocket('ws://localhost:20000');
        
        this.ws.onopen = () => {
            console.log('Connected to C++ NEAT backend');
            // Tell the server we're ready
            this.ws.send(JSON.stringify({ type: 'ready' }));
        };
        
        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleBackendMessage(data);
        };
        
        this.ws.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
        
        this.ws.onclose = () => {
            console.log('Disconnected from C++ backend');
        };
    }
    
    // Handle messages from C++ backend
    handleBackendMessage(data) {
        switch (data.type) {
            case 'genome':
                // Receive new genome from C++ and test it
                this.testGenome(data.genome);
                break;
            case 'evolution_stats':
                // Update evolution statistics
                this.evolutionStats.addFitness(data.generation, data.bestFitness, data.avgFitness);
                break;
            case 'pong':
                // Server ping response
                break;
        }
    }
    
    // Test a genome from the C++ backend
    testGenome(genomeData) {
        // Create a neural network from the genome data
        const network = this.createNetworkFromGenome(genomeData);
        
        // Set the network for the game
        this.game.setNeuralNetwork(network);
        
        // Start the game
        this.game.start();
        
        // Run until the dino dies
        const gameLoop = () => {
            if (this.game.isDead()) {
                // Send fitness back to C++
                this.ws.send(JSON.stringify({
                    type: 'fitness',
                    genomeId: genomeData.id,
                    fitness: this.game.getFitness()
                }));
                
                // Update visualization with this genome
                this.networkViz.updateNetwork(genomeData);
                
                console.log(`Genome ${genomeData.id} completed with fitness: ${this.game.getFitness()}`);
            } else {
                // Continue game
                requestAnimationFrame(gameLoop);
            }
        };
        
        gameLoop();
    }
    
    // Create a neural network from genome data
    createNetworkFromGenome(genomeData) {
        return new NEATNetwork(genomeData);
    }
}

// Initialize application when page loads
document.addEventListener('DOMContentLoaded', () => {
    const app = new DinoGameApp();
    
    // Make app globally accessible for debugging
    window.dinoApp = app;
    
    console.log('Dino Game App initialized!');
    console.log('Controls:');
    console.log('- Space/Up Arrow: Jump');
    console.log('- Down Arrow: Crouch');
    console.log('- Start Training: Begin NEAT evolution');
    console.log('- Pause: Pause training');
    console.log('- Reset: Reset everything');
}); 