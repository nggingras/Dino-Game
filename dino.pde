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
  
  // Define the Dino constructor
  Dino() {}
  
  /******************************* Public method *****************************************/
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
    
    if (dinoDead) {
      noLoop();
    }

    // Update the score
    score++;
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

      if (obstacles.get(i).posX < 0) {
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
