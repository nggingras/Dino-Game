// Main application controller
class DinoGameApp {
    constructor() {
        this.canvas = document.getElementById('gameCanvas');
        this.game = new DinoGame(this.canvas);
        this.networkViz = new NetworkVisualizer('#networkViz');
        this.evolutionStats = new EvolutionStats('#evolutionStats');
        
        this.isTraining = false;
        this.isManual = false;
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
        document.getElementById('startManualBtn').addEventListener('click', () => this.startManual());
        document.getElementById('startBtn').addEventListener('click', () => this.startTraining());
        document.getElementById('resetBtn').addEventListener('click', () => this.resetTraining());
        
        // Keyboard controls for manual play
        document.addEventListener('keydown', (e) => {
            if (this.isManual && !this.isTraining) {
                this.game.handleInput(e.key, true);
            }
        });
        
        document.addEventListener('keyup', (e) => {
            if (this.isManual && !this.isTraining) {
                this.game.handleInput(e.key, false);
            }
        });
        
        // Do NOT start the game automatically
        // this.game.start();

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
    
    // Start manual mode
    startManual() {
        this.isManual = true;
        this.isTraining = false;
        this.currentGeneration = 1;
        this.population = [];
        this.currentGenomeIndex = 0;
        
        this.game.stop();
        this.game.start();
        
        // Hide generation and clear network viz
        document.getElementById('generation').style.display = 'none';
        this.networkViz.clear();
        document.getElementById('networkViz').style.display = 'none';
        
        // Update UI
        document.getElementById('startManualBtn').disabled = true;
        document.getElementById('startBtn').disabled = false;
        
        this.updateStats();
    }

    // Start NEAT training
    startTraining() {
        if (this.isTraining) return;

        this.isTraining = true;
        this.isManual = false;
        this.game.stop();

        // Show generation and network viz
        document.getElementById('generation').style.display = '';
        document.getElementById('networkViz').style.display = '';

        // Instead of initializing a local population, notify the backend to start training
        // The backend will send genomes one by one
        if (this.ws && this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify({ type: 'ready' }));
        }

        // Update UI
        document.getElementById('startManualBtn').disabled = false;
        document.getElementById('startBtn').disabled = true;
    }
    
    // Remove or disable the placeholder initializePopulation and trainingLoop logic
    // initializePopulation() { /* No longer needed, handled by backend */ }
    // trainingLoop() { /* No longer needed, handled by backend */ }
    // evolve() { /* No longer needed, handled by backend */ }
    // createNextGeneration() { /* No longer needed, handled by backend */ }
    // mutateGenome(parent) { /* No longer needed, handled by backend */ }
    
    // Reset training
    resetTraining() {
        window.location.reload();
    }
    
    // Handle WebSocket communication with C++ backend
    setupWebSocket() {
        this.ws = new WebSocket('ws://localhost:20000');
        
        this.ws.onopen = () => {
            console.log('Connected to C++ NEAT backend');
            // Do NOT send 'ready' here!
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
        console.log("Received genome:", genomeData);
        // Create a neural network from the genome data
        const network = this.createNetworkFromGenome(genomeData);
        // Set the network for the game
        this.game.setNeuralNetwork(network);
        // Draw the network immediately
        this.networkViz.updateNetwork(genomeData);
        // Start the game
        this.game.start();
        // Run until the dino dies
        const gameLoop = () => {
            // Real-time input/output visualization
            if (this.game.neuralNetwork) {
                const gameState = this.game.getGameState();
                const inputs = [
                    gameState.dinoY / 100,
                    gameState.dinoVelocity / 20,
                    gameState.obstacleX / this.game.canvas.width,
                    gameState.obstacleHeight / 120
                ];
                const outputs = this.game.neuralNetwork.getOutputs();
                this.networkViz.updateRealTime(inputs, outputs);
            }
            if (this.game.isDead()) {
                // Send fitness back to C++
                this.ws.send(JSON.stringify({
                    type: 'fitness',
                    genomeId: genomeData.id,
                    fitness: this.game.getFitness()
                }));
                // Update visualization with this genome (final state)
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
    // Hide generation and network viz by default
    document.getElementById('generation').style.display = 'none';
    document.getElementById('networkViz').style.display = 'none';
    // Make app globally accessible for debugging
    window.dinoApp = app;
    
    console.log('Dino Game App initialized!');
    console.log('Controls:');
    console.log('- Space/Up Arrow: Jump');
    console.log('- Down Arrow: Crouch');
    console.log('- Start Training: Begin NEAT evolution');
    console.log('- Reset: Reset everything');
    // Do NOT start the game automatically here
}); 