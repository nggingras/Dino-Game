// Define a class named Obstacles
class Obstacles {
  // Declare instance variables for the Obstacle's position, width, height, and type
  float posX;
  float posY; // Used for birds height 
  int w;
  int h;
  int type;
  
  // Flap the bird
  int flap = 0;
  
  // Declare constants for the different types of obstacles
  final int eSmallCactus = 0;
  final int eSmallCactusMany = 1;
  final int eBigCactus = 2;
  final int eBirdLow = 3;
  final int eBirdMiddle = 4;
  final int eBirdHigh = 5;
 
  // Define the Obstacles constructor
  Obstacles(int _type) {
    // Initialize the position to the width of the screen (so it starts offscreen to the right)
    posX = width;
    
    // Set the type of the obstacle
    type = _type;
    
    // Set the width and height of the obstacle based on its type
    switch (type) {
      case eSmallCactus:
        w = 40;
        h = 80;
        posY = 0;
        break;
      case eSmallCactusMany:
        w = 40;
        h = 80;
        posY = 0;
        break;
      case eBigCactus:
        w = 60;
        h = 120;
        posY = 0;
        break;
      case eBirdLow:
        w = 60;
        h = 50;
        posY = 40; 
        break;
      case eBirdMiddle:
        w = 60;
        h = 50;
        posY = 120; 
        break;
      case eBirdHigh:
        w = 60;
        h = 50;
        posY = 160; // Higher bird (can't jump over)
        break;
    }
  }
  
  // Define a method to display the obstacle
  void show() {
    // Set the fill color to black
    fill(0);

    // Set the rectangle mode to CENTER (so the position is the center of the rectangle, not the top-left corner)
    rectMode(CENTER);

    // Depending on the type of obstacle, draw the appropriate image
    switch(type) {
      case eSmallCactus:
        image(smallCactus, posX - smallCactus.width/2, height - groundHeight - smallCactus.height);
        break;  
      case eSmallCactusMany:
        image(smallCactusMany, posX - smallCactus.width/2, height - groundHeight - smallCactus.height);
        break; 
      case eBigCactus:
        image(bigCactus, posX - bigCactus.width/2, height - groundHeight - bigCactus.height);
        break;
      case eBirdLow:
      case eBirdMiddle:
      case eBirdHigh:
        if (flap < 10) {
          image(bird, posX - bird.width/2, height - groundHeight - (posY + bird.height - 20));
        }
        else {
          image(bird1, posX - bird1.width/2, height - groundHeight - (posY + bird1.height - 20));
        }
        break;
    }
    flap++;
    if (flap > 20) {
        flap = 0;
    }
  }
  
  // Define a method to move the obstacle
  void move(float speed) {
    // Decrease the x position of the obstacle by the speed (to move it to the left)
    posX -= speed;
  }

  // Define a method to check if the obstacle collided with the dino
   boolean isCollision(float dinoX, float dinoY, float dinoW, float dinoH) {
    
    float dinoLeft = dinoX - dinoW/2;
    float dinoRight = dinoX + dinoW/2;
    
    float obsLeft = posX - w/2;
    float obsRight = posX + w/2;

    // Check x-axis collision
    if((dinoLeft <= obsRight && dinoRight >= obsLeft) || (dinoRight >= obsLeft && dinoLeft <= obsRight)) {
      float dinoBottom = dinoY - dinoH/2;   
      float dinoTop = dinoY + dinoH/2;
      float obsTop = posY + h/2;
      float obsBottom = posY - h/2;
      
      // Check y-axis collision
      if (dinoBottom <= obsTop && dinoTop >= obsBottom) {
        return true;
      }
    }

     // If none of the above are true, then the obstacle is not colliding with the dino
     return false;
   }
 }
