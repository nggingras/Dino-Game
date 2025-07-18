# Dino Game - Web Version

This is a JavaScript/HTML5 version of the Processing Dino game, designed for NEAT (NeuroEvolution of Augmenting Topologies) training and visualization.

## Features

- **Exact Processing Replica**: Same game mechanics, physics, and visual style as the original Processing version
- **NEAT Integration Ready**: Built-in support for neural network control
- **Real-time Visualization**: D3.js neural network visualization with live updates
- **Evolution Statistics**: Charts showing fitness progression over generations
- **Manual Play**: Can be played manually with keyboard controls
- **AI Training**: Automated training with visual feedback

## Controls

### Manual Play
- **Space** or **Up Arrow**: Jump
- **Down Arrow**: Crouch

### Training Controls
- **Start Training**: Begin NEAT evolution
- **Pause**: Pause/resume training
- **Reset**: Reset everything

## File Structure

```
web/
├── index.html              # Main HTML file
├── css/
│   └── style.css          # Styling
├── js/
│   ├── dinoGame.js        # Game logic (Dino and Obstacle classes)
│   ├── networkViz.js      # D3.js neural network visualization
│   └── main.js            # Main application controller
└── assets/
    └── images/            # Game sprites (to be added)
```

## Game Mechanics

The game replicates the exact mechanics from the Processing version:

- **Dino Physics**: Gravity, jumping, crouching
- **Obstacle Types**: Small cactus, big cactus, multiple cacti, birds at different heights
- **Collision Detection**: Precise collision detection matching the original
- **Scoring**: Score increases while alive
- **Speed Progression**: Game speed gradually increases

## AI Integration

The game is designed to work with NEAT algorithms:

- **Input Neurons**: 4 inputs (dino Y position, velocity, nearest obstacle X, obstacle height)
- **Output Neurons**: 2 outputs (jump decision, crouch decision)
- **Fitness Function**: Score (distance traveled)
- **Real-time Control**: Neural networks can control the dino in real-time

## Visualization Features

- **Network Structure**: Interactive D3.js visualization of neural network topology
- **Connection Weights**: Color-coded connections (green=positive, red=negative)
- **Node Activation**: Real-time node size changes based on activation
- **Evolution Charts**: Fitness progression over generations

## Usage

1. Open `index.html` in a web browser
2. Play manually with keyboard controls
3. Click "Start Training" to begin AI evolution
4. Watch the neural networks evolve in real-time

## Integration with C++ Backend

The web frontend is designed to communicate with a C++ NEAT backend via WebSocket:

- **WebSocket Protocol**: Real-time communication
- **JSON Messages**: Genome data, fitness scores, evolution statistics
- **Modular Design**: Easy to replace dummy AI with real NEAT implementation

## Future Enhancements

- [ ] Add actual game sprites from Processing version
- [ ] Implement WebSocket connection to C++ backend
- [ ] Add sound effects
- [ ] Improve network visualization
- [ ] Add more detailed statistics
- [ ] Implement save/load functionality

## Technical Details

- **Canvas Rendering**: HTML5 Canvas for game graphics
- **D3.js**: Neural network and statistics visualization
- **ES6 Classes**: Modern JavaScript architecture
- **RequestAnimationFrame**: Smooth 60 FPS game loop
- **Modular Design**: Clean separation of concerns 