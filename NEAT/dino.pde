// Define a class named Dino
class Dino {
  
  // Declare instance variables for the Dino's position, velocity, gravity, and speed
  float posY = 0;
  float velY = 0;
  float gravity = 0.6;

  // Declare instance variables for managing the Dino's jumping and crouching
  boolean isCrouching = false;
  boolean dinoDead = false;

  // Declare an instance variable for the Dino's size
  int dinoX = 150;
  int dinoWalk = 0;
  int score = 0;
  
  // AI-related variables
  Genotype brain;
  boolean isAI = false;
  
  // Define the Dino constructor
  Dino() {}
  
  // Constructor with AI brain
  Dino(Genotype _brain) {
    brain = _brain;
    isAI = true;
  }
  
  /******************************* Public method *****************************************/
  // AI decision making
  void think(ObstacleManager obstacleManager) {
    if (!isAI || brain == null) return;
    
    float[] inputs = getSensorInputs(obstacleManager);
    float[] outputs = brain.feedForward(inputs);
    
    // Interpret outputs
    boolean shouldJump = outputs[0] > 0.5;
    boolean shouldDuck = outputs[1] > 0.5;
    
    // Apply actions
    if (shouldJump && posY == 0) {
      velY = 16;
      isCrouching = false;
    } else if (shouldDuck) {
      isCrouching = true;
    } else {
      isCrouching = false;
    }
  }
  
  // Get sensor inputs for the neural network
  float[] getSensorInputs(ObstacleManager obstacleManager) {
    float[] inputs = new float[4];
    
    // Find the closest obstacle
    Obstacles closestObstacle = obstacleManager.getClosestObstacle(dinoX);
    
    if (closestObstacle != null) {
      // Distance to obstacle (normalized)
      inputs[0] = (closestObstacle.positionX - dinoX) / width;
      
      // Obstacle height (normalized)
      inputs[1] = closestObstacle.obstacleHeight / 200.0;
      
      // Obstacle type (bird = 1, cactus = 0) 
      inputs[2] = (closestObstacle.type >= 3) ? 1.0 : 0.0;
      
      // Dino's current Y position (normalized)
      inputs[3] = posY / 200.0;
    } else {
      // No obstacle, neutral inputs
      inputs[0] = 1.0;  // Far distance
      inputs[1] = 0.0;  // No height
      inputs[2] = 0.0;  // No obstacle
      inputs[3] = posY / 200.0;
    }
    
    return inputs;
  }
  
  // Calculate fitness for this dino
  float calculateFitness() {
    if (brain == null) return score;
    
    float fitness = score; // Base fitness from survival time
    
    // Bonus for staying alive longer
    if (!dinoDead) {
      fitness += 50;
    }
    
    // Bonus for high scores
    fitness += score * 0.1;
    
    return fitness;
  }
  
  // Define a method to display the Dino (without obstacles)
  void show() {
    // Set the fill color to black
    fill(0);
    
    drawDino();
    updateDinoWalk();
  }

  // Define a method to move the Dino (without obstacle management)
  void move() {
    updateDinoPosition();
    updateScore();
  }
  
  // Define a method to return dead or alive state of the Dino
  boolean isDead() {
    return dinoDead;
  }

  /***************************** Private method ******************************************/
  // Define a method to draw the Dino
  private void drawDino() {
    if(isCrouching) {
      drawCrouchingDino();
    } else {
      drawRunningDino();
    }
  }

  // Draw the dino in crouching state
  private void drawCrouchingDino() {
    if (dinoWalk < 0) {
      image(dinoDuck, dinoX - dinoDuck.width/2, height - groundHeight - (posY + dinoDuck.height));
    } else {
      image(dinoDuck1, dinoX - dinoDuck1.width/2, height - groundHeight - (posY + dinoDuck1.height));
    } 
  }
    // Draw the dino in running state
  private void drawRunningDino() {
    if (dinoWalk < 0) {
      image(dinoRun1, dinoX - dinoRun1.width/2, height - groundHeight- (posY + dinoRun1.height));
    } else {
      image(dinoRun2, dinoX - dinoRun2.width/2, height - groundHeight - (posY + dinoRun2.height));
    } 
  }
  
  // Define a method to make the Dino walk. The Dino will switch between two images to create the walking effect
  private void updateDinoWalk() {
    dinoWalk++;
    if (dinoWalk > 10) {
        dinoWalk = -10;
    }
  }

  // Define a method to update the Dino's position
  private void updateDinoPosition() {
    // Update the Dino's vertical position based on its velocity
    posY += velY;
    
    // If the Dino is in the air, apply gravity to its velocity
    if (posY > 0) {
      velY -= gravity;
    }
    // If the Dino is on the ground, reset its velocity and position
    else {
      velY = 0;
      posY = 0;
    }
  }

  // Define a method to update the score on the screen
  private void updateScore() {
    if (!dinoDead) {
      score++;
    }
  }
}
