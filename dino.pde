// Define a class named Dino
class Dino {
  
  // Declare instance variables for the Dino's position, velocity, gravity, and speed
  float posY = 0;
  float velY = 0;
  float gravity = 0.6;
  float speed = 5;

  // Declare instance variables for managing the Dino's running animation
  boolean isDinoRun1 = true;

  // Declare instance variables for managing the Dino's jumping and crouching
  boolean isCrouching = false;

  // Declare an instance variable for the Dino's size
  int size = 60;
  
  // Declare instance variables for managing the timing of obstacle creation
  int timerBetweenObstacles = 0;
  int minimumTimeBetweenObstacles = 50;
  int randomAdditionOfNewObstacles = floor(random(50));
  
  // Declare an ArrayList to hold Obstacle objects
  ArrayList<Obstacles> obstacles = new ArrayList<Obstacles>();
  
  // Define the Dino constructor
  Dino() {
    
  }
  
  // Define a method to display the Dino and obstacles
  void show() {
    // Set the fill color to black
    fill(0);

    // Draw a rectangle to represent the Dino
    if(isCrouching) {
      image(dinoDuck, 40, height - 120 - (posY + size), size, size * 2); //<>//
    }
    
    if (isDinoRun1) {
      image(dinoRun1, 40, height - 120 - (posY + size), size, size * 2);
    } else {
      image(dinoRun2, 40, height - 120 - (posY + size), size, size * 2);
    } //<>//

    // Flip the flag for the next call to show()
    isDinoRun1 = !isDinoRun1;

    // Loop through the obstacles ArrayList and call the show method on each Obstacle
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).show();
    }
  }

  // Define a method to move the Dino and obstacles
  void move() {
    // Gradually increase the speed
    speed += 0.001;
    
    // Increment the timer between obstacles
    timerBetweenObstacles += 1;
    // If enough time has passed, add a new obstacle
    if (timerBetweenObstacles > (minimumTimeBetweenObstacles + randomAdditionOfNewObstacles)) {
      addObstacle();
      // Reset the timer and generate a new random time for the next obstacle
      timerBetweenObstacles = 0;
      randomAdditionOfNewObstacles = floor(random(50));
    }
    
    // Update the Dino's vertical position based on its velocity
    posY += velY;
    println(posY);
    
    // If the Dino is in the air, apply gravity to its velocity
    if (posY > 0) {
      velY -= gravity;
    }
    // If the Dino is on the ground, reset its velocity and position
    else {
      velY = 0;
      posY = 0;
    }
    // Move each obstacle and remove it if it's off the screen
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).move(speed);
      if (obstacles.get(i).posX < 0) {
        obstacles.remove(i);
      }
    }
  }
  
  // Define a method to add an obstacle
  void addObstacle() {
    // Create a new Obstacle and add it to the ArrayList
    Obstacles obstacle = new Obstacles(floor(random(3)));
    obstacles.add(obstacle);
  }
}
