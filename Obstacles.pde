// Define a class named Obstacles
class Obstacles {
  // Declare instance variables for the Obstacle's position, width, height, and type
  float posX;
  int w;
  int h;
  int type;
  
  // Flap the bird
  int flap = 0;
  
  // Declare constants for the different types of obstacles
  final int eSmallCactus = 0;
  final int eBigCactus = 1;
  final int eBird = 2;
 
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
        break;
      case eBigCactus:
        w = 60;
        h = 120;
        break;
      case eBird:
        w = 40;
        h = 50;
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
        image(smallCactus, posX, height - 100 - h/2, w, h);
        break;
      case eBigCactus:
        image(bigCactus, posX , height - 110 - h/2, w, h);
        break;
      case eBird:
        if (flap < 10) {
          image(bird, posX, height - 160 - h/2, w, h);
        }
        else {
          image(bird1, posX, height - 160 - h/2, w, h);
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
   boolean isBoomBoom(float dinoX, float dinoY, int dinoW, int dinoH) {
    
     // Calculate the left, right, top, and bottom of the dino
     float dinoLeft = dinoX - dinoW/2;
     float dinoRight = dinoX + dinoW/2;
     float dinoTop = dinoY - dinoH/2;
     float dinoBottom = dinoY + dinoH/2;
    
    // Calculate the left, right, top, and bottom of the obstacle
    float obsLeft = posX - w/2;
    float obsRight = posX + w/2;
    float obsTop = height - 100 - h/2;
    float obsBottom = height - 100 + h/2;

    // Check if dino boom boom
    if((dinoLeft <= obsRight && dinoRight >= obsLeft)) {
      return true;
    }

     // If none of the above are true, then the obstacle is colliding with the dino
     return true;
   }
 }
