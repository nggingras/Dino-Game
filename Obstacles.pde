// Define a class named Obstacles
class Obstacles {
  // Position and size variables
  float positionX;
  float positionY; // Used for bird's height 
  int obstacleWidth;
  int obstacleHeight;

  // Obstacle type and bird flap state
  int type;
  int birdFlapState = 0;
  
  // Obstacle types
  final int SMALL_CACTUS = 0;
  final int SMALL_CACTUS_MANY = 1;
  final int BIG_CACTUS = 2;
  final int BIRD_LOW = 3;
  final int BIRD_MIDDLE = 4;
  final int BIRD_HIGH = 5;
 
  // Define the Obstacles constructor
  Obstacles(int _type) {
    this.positionX = width; // Initialize the position to the width of the screen
    this.type = _type; // Set the type of the obstacle
    setObstacleSizeAndPosition(); // Set the size and position based on the type
  }

  // Set the size and position based on the obstacle type
  void setObstacleSizeAndPosition() {
    switch (type) {
      case SMALL_CACTUS:
      case SMALL_CACTUS_MANY:
        this.obstacleWidth = 40;
        this.obstacleHeight = 80;
        this.positionY = 0;
        break;
      case BIG_CACTUS:
        this.obstacleWidth = 60;
        this.obstacleHeight = 120;
        this.positionY = 0;
        break;
      case BIRD_LOW:
        this.obstacleWidth = 60;
        this.obstacleHeight = 50;
        this.positionY = 40; 
        break;
      case BIRD_MIDDLE:
        this.obstacleWidth = 60;
        this.obstacleHeight = 50;
        this.positionY = 120; 
        break;
      case BIRD_HIGH:
        this.obstacleWidth = 60;
        this.obstacleHeight = 50;
        this.positionY = 160; // Higher bird (can't jump over)
        break;
    }
  }
  
 // Display the obstacle
  void show() {
    fill(0);
    rectMode(CENTER);
    drawObstacle();
  }

  // Draw the obstacle based on its type
  void drawObstacle() {
    switch(type) {
      case SMALL_CACTUS:
        image(smallCactus, positionX - smallCactus.width/2, height - groundHeight - smallCactus.height);
        break;  
      case SMALL_CACTUS_MANY:
        image(smallCactusMany, positionX - smallCactus.width/2, height - groundHeight - smallCactus.height);
        break; 
      case BIG_CACTUS:
        image(bigCactus, positionX - bigCactus.width/2, height - groundHeight - bigCactus.height);
        break;
      case BIRD_LOW:
      case BIRD_MIDDLE:
      case BIRD_HIGH:
        drawBird();
        break;
    }
  }

  // Draw the bird obstacle
  void drawBird() {
    if (birdFlapState < 10) {
      image(bird, positionX - bird.width/2, height - groundHeight - (positionY + bird.height - 20));
    } else {
      image(bird1, positionX - bird1.width/2, height - groundHeight - (positionY + bird1.height - 20));
    }
    birdFlapState++;
    if (birdFlapState > 20) {
      birdFlapState = 0;
    }
  }
  
  // Move the obstacle
  void move(float speed) {
    positionX -= speed;
  }

  // Check if the obstacle collided with the dino
  boolean isCollision(float dinoX, float dinoY, float dinoWidth, float dinoHeight) {
    // Check x-axis collision
    if(isXAxisCollision(dinoX, dinoWidth)) {
      // Check y-axis collision
      if(isYAxisCollision(dinoY, dinoHeight)) {
        return true;
      }
    }
    return false;
  }

  // Check if there is a collision on the x-axis
  boolean isXAxisCollision(float dinoX, float dinoWidth) {
    float dinoLeft = dinoX - dinoWidth/2;
    float dinoRight = dinoX + dinoWidth/2;
    float obstacleLeft = positionX - obstacleWidth/2;
    float obstacleRight = positionX + obstacleWidth/2;
    return (dinoLeft <= obstacleRight && dinoRight >= obstacleLeft) || (dinoRight >= obstacleLeft && dinoLeft <= obstacleRight);
  }

  // Check if there is a collision on the y-axis
  boolean isYAxisCollision(float dinoY, float dinoHeight) {
    float dinoBottom = dinoY - dinoHeight/2;   
    float dinoTop = dinoY + dinoHeight/2;
    float obstacleTop = positionY + obstacleHeight/2;
    float obstacleBottom = positionY - obstacleHeight/2;
    return dinoBottom <= obstacleTop && dinoTop >= obstacleBottom;
  }
}