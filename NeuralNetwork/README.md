# NEAT Dino Game - WebSocket Integration

This project implements a NEAT (NeuroEvolution of Augmenting Topologies) algorithm that trains AI agents to play a Dino game through WebSocket communication between C++ and JavaScript.

## Architecture

- **C++ Backend**: NEAT algorithm server (console application)
- **Web Frontend**: Dino game + neural network visualization (browser)
- **Communication**: WebSocket protocol for real-time data exchange

## Features

- **Pure NEAT Implementation**: C++ handles all evolution logic
- **Real-time Visualization**: Browser shows game, neural networks, and evolution stats
- **No GUI Dependencies**: C++ runs as a clean console application
- **Cross-platform**: Works on any system with a web browser

## Setup

### Prerequisites

1. **C++ Dependencies** (install via vcpkg or your preferred method):
   ```bash
   vcpkg install websocketpp nlohmann-json
   ```

2. **Web Browser**: Any modern browser (Chrome, Firefox, Edge, etc.)

### Building

1. **Build the C++ server**:
   ```bash
   build.bat
   ```
   Or manually:
   ```bash
   msbuild NeuralNetwork.sln /p:Configuration=Debug /p:Platform=x64
   ```

2. **Run the server**:
   ```bash
   x64\Debug\NeuralNetwork.exe
   ```

3. **Open the web client**:
   - Open `web/index.html` in your browser
   - The client will automatically connect to the server

## How It Works

### 1. C++ NEAT Server
- Runs on port 8080
- Manages population of neural networks
- Sends genomes to web client for testing
- Receives fitness scores and evolves population

### 2. Web Client
- Connects to C++ server via WebSocket
- Receives genome data and creates neural network
- Runs the Dino game with AI control
- Sends fitness results back to server
- Visualizes neural networks and evolution stats

### 3. Communication Protocol

**C++ → Web:**
```json
{
  "type": "genome",
  "genome": {
    "id": 123,
    "numInputs": 4,
    "numOutputs": 2,
    "nodes": [...],
    "connections": [...]
  }
}
```

**Web → C++:**
```json
{
  "type": "fitness",
  "genomeId": 123,
  "fitness": 456.7
}
```

## Game Controls

- **Manual Play**: Space/Up Arrow to jump, Down Arrow to crouch
- **AI Training**: Automatic (controlled by neural networks)
- **Visualization**: Real-time neural network graphs and evolution charts

## NEAT Configuration

The NEAT algorithm is configured in `src/main.cpp`:

```cpp
NEAT::Config config;
config.populationSize = 30;
config.numInputs = 4;  // dinoY, dinoVelocity, obstacleX, obstacleHeight
config.numOutputs = 2; // jump decision, crouch decision
config.compatibilityThreshold = 3.0;
config.weightMutationRate = 0.1;
config.addNodeMutationRate = 0.03;
config.addConnectionMutationRate = 0.05;
```

## File Structure

```
NeuralNetwork/
├── src/                    # C++ NEAT implementation
│   ├── main.cpp           # WebSocket server + NEAT logic
│   ├── NEAT.h/cpp         # NEAT algorithm
│   ├── neuralNetwork.h/cpp # Neural network implementation
│   ├── Node.h/cpp         # Network nodes
│   └── Connection.h/cpp   # Network connections
├── web/                   # Web frontend
│   ├── index.html         # Main page
│   ├── js/
│   │   ├── dinoGame.js    # Dino game logic
│   │   ├── neuralNetwork.js # NEAT network runner
│   │   ├── networkViz.js  # D3.js visualizations
│   │   └── main.js        # WebSocket client
│   ├── css/style.css      # Styling
│   └── assets/images/     # Game sprites
├── build.bat              # Build script
└── README.md              # This file
```

## Troubleshooting

### WebSocket Connection Issues
- Ensure the C++ server is running on port 8080
- Check firewall settings
- Verify the web client is connecting to `ws://localhost:8080`

### Build Issues
- Install required dependencies (websocketpp, nlohmann-json)
- Ensure Visual Studio is properly configured
- Check that all source files are included in the project

### Performance
- The C++ server handles all heavy computation
- The web client focuses on visualization and game rendering
- For large populations, consider running the server on a more powerful machine

## Future Enhancements

- [ ] Add more NEAT parameters (speciation, crossover, etc.)
- [ ] Implement save/load functionality for trained networks
- [ ] Add more detailed statistics and visualizations
- [ ] Support for multiple concurrent clients
- [ ] Distributed training across multiple machines

## Credits

- **NEAT Algorithm**: Based on Kenneth Stanley's NeuroEvolution of Augmenting Topologies
- **Dino Game**: Inspired by Google Chrome's offline T-Rex game
- **WebSocket**: Real-time communication between C++ and JavaScript
- **D3.js**: Neural network and statistics visualization 