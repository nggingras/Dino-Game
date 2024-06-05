// Declare a Dino object
Dino dino;

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
  dinoRun1 = loadImage("dinorun0000.png");
  dinoRun2 = loadImage("dinorun0001.png");
  dinoJump = loadImage("dinoJump0000.png");
  dinoDuck = loadImage("dinoduck0000.png");
  dinoDuck1 = loadImage("dinoduck0001.png");

  smallCactus = loadImage("cactusSmall0000.png");
  bigCactus = loadImage("cactusBig0000.png");
  smallCactusMany = loadImage("cactusSmallMany0000.png");
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
  strokeWeight(2);
  // Draw a line
  line(0, height - groundHeight - 30, width, height - groundHeight - 30);
  
  // Move and show the dino
  dino.move();
  dino.show();

  if (dino.isDead()){
    noLoop();
  }

  writeScore();
}

// The keyPressed function is called once every time a key is pressed
void keyPressed() {
  if (key == ' ' || keyCode == UP) {
    dino.isCrouching = false;
    if (dino.posY == 0) {
      dino.velY = 16;
    }
  } else if (keyCode == DOWN) {
    dino.isCrouching = true;
  }
}

// The keyReleased function is called once every time a key is released
void keyReleased() {
  if (keyCode == DOWN) {
    dino.isCrouching = false;
  }
}

// Write score on screen
void writeScore() {
  fill(0);
  textAlign(LEFT);
  textSize(30);
  text("Score", 10, height - 1050);
  text(dino.score, 10, height - 1020);
}
