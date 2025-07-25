// Declare Population for NEAT algorithm
Population population;

// Declare neural network visualization
NetworkVisualization networkViz;

// Declare PImage objects for different images
PImage dinoRun1, dinoRun2, dinoJump, dinoDuck, dinoDuck1;
PImage smallCactus, smallCactusMany, bigCactus;
PImage bird, bird1;

// Global
int groundHeight = 250;

// The setup function runs once when the program starts
void setup() {
  // Set the size of the display window
  frameRate(60);
  fullScreen();
  
  // Load images from the sketch's "data" directory
  dinoRun1 = loadImage("../data/dinorun0000.png");
  dinoRun2 = loadImage("../data/dinorun0001.png");
  dinoJump = loadImage("../data/dinoJump0000.png");
  dinoDuck = loadImage("../data/dinoduck0000.png");
  dinoDuck1 = loadImage("../data/dinoduck0001.png");
  
  smallCactus = loadImage("../data/cactusSmall0000.png");
  bigCactus = loadImage("../data/cactusBig0000.png");
  smallCactusMany = loadImage("../data/cactusSmallMany0000.png");
  bird = loadImage("../data/berd.png");
  bird1 = loadImage("../data/berd2.png");

  // Create population for NEAT algorithm
  population = new Population();
  
  // Create network visualization
  networkViz = new NetworkVisualization();
}

// The draw function continuously executes the lines of code contained inside its block until the program is stopped
void draw() {
  // Set the background color
  background(255);
  // Set the color used to draw lines and borders around shapes
  stroke(0);
  strokeWeight(2);
  // Draw a line
  line(0, height - groundHeight - 30, width, height - groundHeight - 30);
  
  // Update and show population
  if (population.shouldEvolve()) {
    population.evolve();
  } else {
    population.update();
    population.show();
  }
  
  // Draw neural network visualization overlay
  networkViz.draw(population);
  
  // Display statistics
  writeStats();
}

// Manual override controls (for testing)
void keyPressed() {
  if (key == 'r' || key == 'R') {
    // Reset population
    population = new Population();
  }
  if (key == 'v' || key == 'V') {
    // Toggle network visualization
    networkViz.toggleVisibility();
  }
}

// Write statistics on screen
void writeStats() {
  fill(0);
  textAlign(LEFT);
  textSize(20);
  text(population.getStats(), 10, 30);
  
  // Show additional info
  text("Press 'R' to reset", 10, height - 50);
  text("Press 'V' to toggle network visualization", 10, height - 30);
  
  // Highlight best performing dino
  if (population.aliveCount > 0) {
    Dino bestDino = null;
    float bestScore = -1;
    for (Dino dino : population.dinos) {
      if (!dino.isDead() && dino.score > bestScore) {
        bestScore = dino.score;
        bestDino = dino;
      }
    }
    
    if (bestDino != null) {
      // Draw a circle around the best dino
      stroke(255, 0, 0);
      strokeWeight(3);
      noFill();
      ellipse(bestDino.dinoX, height - groundHeight - (bestDino.posY + 50), 100, 100);
      
      // Reset stroke
      stroke(0);
      strokeWeight(2);
      
      text("Best Score: " + bestScore, 10, 60);
    }
  }
}
