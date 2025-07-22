// Define a class named Dino
class Dino {
  
  // Declare instance variables for the Dino's position, velocity, gravity, and speed
  float posY = 0;
  float velY = 0;
  float gravity = 0.6;
  float speed = 5;

  // Declare instance variables for managing the Dino's jumping and crouching
  boolean isCrouching = false;
  boolean dinoDead = false;

  // Declare an instance variable for the Dino's size
  int dinoX = 150;
  int dinoWalk = 0;
  int score = 0;
  
  // Declare instance variables for managing the timing of obstacle creation
  int timerBetweenObstacles = 0;
  int minimumTimeBetweenObstacles = 100;
  int randomAdditionOfNewObstacles = floor(random(50));
  
  // Declare an ArrayList to hold Obstacle objects
  ArrayList<Obstacles> obstacles = new ArrayList<Obstacles>();
  
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
  void think() {
    if (!isAI || brain == null) return;
    
    float[] inputs = getSensorInputs();
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
  float[] getSensorInputs() {
    float[] inputs = new float[4];
    
    // Find the closest obstacle
    Obstacles closestObstacle = getClosestObstacle();
    
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
  
  // Find the closest obstacle ahead of the dino
  Obstacles getClosestObstacle() {
    Obstacles closest = null;
    float closestDistance = Float.MAX_VALUE;
    
    for (Obstacles obstacle : obstacles) {
      if (obstacle.positionX > dinoX) { // Only consider obstacles ahead
        float distance = obstacle.positionX - dinoX;
        if (distance < closestDistance) {
          closestDistance = distance;
          closest = obstacle;
        }
      }
    }
    
    return closest;
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
  
  // Define a method to display the Dino and obstacles
  void show() {
    // Set the fill color to black
    fill(0);
    
    drawDino();
    updateDinoWalk();
    displayObstacles();
  }

  // Define a method to move the Dino and obstacles
  void move() {

    updateSpeed();
    addObstacle();
    updateDinoPosition();
    updateObstacles();

    // Update the score
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

  // Loop through the obstacles ArrayList and call the show method on each Obstacle
  private void displayObstacles() {
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).show();
    }
  }

  // Define a method to update the speed of the game
  private void updateSpeed() {
    speed += 0.001;
  }

  // Loop through the obstacles ArrayList and call the move method on each Obstacle
  // Check for collisions between the Dino and each obstacle
  // If an obstacle moves off the screen, remove it from the ArrayList
  private void updateObstacles() {
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).move(speed);
      
      checkCollision(i);

      if ((obstacles.get(i).positionX + obstacles.get(i).obstacleWidth) < 0) {
        obstacles.remove(i);
      }
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

  // Define a method to check collision between obstacles and the Dino
  // Return true if the Dino collides with an obstacle
  private void checkCollision(int i) {
    if(obstacles.get(i).isCollision(dinoX, posY + ((isCrouching) ? dinoDuck.height/2 : dinoRun1.height/2), dinoRun1.width*0.5, dinoRun1.height)) {
      dinoDead = true;
    }
  }

  // Define a method to update the score on the screen
  private void updateScore() {
    if (!dinoDead) {
      score++;
    }
  }

  // Define a method to add an obstacle
  private void addObstacle() {

    // Increment the timer between obstacles
    timerBetweenObstacles += 1;

    // If enough time has passed, add a new obstacle
    if (timerBetweenObstacles > (minimumTimeBetweenObstacles + randomAdditionOfNewObstacles)) {
      Obstacles obstacle = new Obstacles(floor(random(6)));
      obstacles.add(obstacle);

      // Reset the timer and generate a new random time for the next obstacle
      timerBetweenObstacles = 0;
      randomAdditionOfNewObstacles = floor(random(50));
    }
  }
}
