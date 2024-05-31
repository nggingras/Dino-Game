// Declare a Dino object
Dino dino;

// Declare PImage objects for different images
PImage dinoRun1;
PImage dinoRun2;
PImage dinoJump;
PImage dinoDuck;
PImage dinoDuck1;
PImage smallCactus;
PImage manySmallCactus;
PImage bigCactus;
PImage bird;
PImage bird1;

// The setup function runs once when the program starts
void setup() {
  // Set the size of the display window
  size(800,400);
  
  // Load images from the sketch's "data" directory
  dinoRun1 = loadImage("dinorun0000.png");
  dinoRun2 = loadImage("dinorun0001.png");
  dinoJump = loadImage("dinoJump0000.png");
  dinoDuck = loadImage("dinoduck0000.png");
  dinoDuck1 = loadImage("dinoduck0001.png");

  smallCactus = loadImage("cactusSmall0000.png");
  bigCactus = loadImage("cactusBig0000.png");
  manySmallCactus = loadImage("cactusSmallMany0000.png");
  bird = loadImage("berd.png");
  bird1 = loadImage("berd2.png");
  
  // Create a new Dino object
  dino = new Dino();  
}

// The draw function continuously executes the lines of code contained inside its block until the program is stopped
void draw() {
  // Set the background color
  background(255);
  // Set the color used to draw lines and borders around shapes
  stroke(0);
  // Draw a line
  line(0, height - 100, width, height - 100);
  // Move the dino
  dino.move();
  // Show the dino
  dino.show();

  // print score
  fill(0);
  textAlign(LEFT);
  textSize(20);
  text("Score", 10, height - 375);
  text(dino.score, 10, height - 355);
}

// The keyPressed function is called once every time a key is pressed
void keyPressed() {
  // Check which key was pressed
  switch (key) {
  // Space bar  
  case ' ':
    dino.isCrouching = false;
    
    // If the dino is on the ground, make it jump
    if (dino.posY == 0) {
      dino.velY = 12;
    }
    break;
  case CODED:
    switch (keyCode) {
      case DOWN:
      // Make the dino crouch
      dino.isCrouching = true;
      break;
    }
    break;
  }
}

// The keyReleased function is called once every time a key is released
void keyReleased() {
  // Check which key was pressed
  switch (key) {
  case CODED:
    switch (keyCode) {
      case DOWN:
      // Make the dino stand
      dino.isCrouching = false;
      break;
    }
    break;
  }
}
