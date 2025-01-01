// Declare a Population object
Population pop;

// Declare PImage objects for different images
PImage dinoRun1, dinoRun2, dinoJump, dinoDuck, dinoDuck1;
PImage smallCactus, smallCactusMany, bigCactus;
PImage bird, bird1;

// Global
int groundHeight = 250;
int maxPopulation = 10;
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

  // Create a new Dino object
  pop = new Population(0.1, maxPopulation);  
}

// The draw function continuously executes the lines of code contained inside its block until the program is stopped
void draw() {

  setBackground();

  // Move and show the dino
  //dino.think();
  for (int dinoIndex = 0; dinoIndex < pop.dinoList.size(); dinoIndex++) {
    pop.dinoList.get(dinoIndex).move();
    pop.dinoList.get(dinoIndex).show();
    writeScore(dinoIndex);

    // test
    int randomNumber = floor(random(9, 100));
    if (randomNumber < 10) {
      if (pop.dinoList.get(dinoIndex).posY == 0) {
        pop.dinoList.get(dinoIndex).velY = 16;
      }
    }
  }

  //Function to add with GA
  // population.calcFitness(); //step 2. Selection - evaluation fitness of each element
  // population.naturalSelection();
  // population.generate();
  // population.evaluate();

  // if (pop.pop.get(dinoIndex).isDead()){
  //     // stop the game
  //     noLoop();
  // }
}

// The keyPressed function is called once every time a key is pressed
// void keyPressed() {
//   if (key == ' ' || keyCode == UP) {
//     dino.isCrouching = false;
//     if (dino.posY == 0) {
//       dino.velY = 16;
//     }
//   } else if (keyCode == DOWN) {
//     dino.isCrouching = true;
//   }
// }

// The keyReleased function is called once every time a key is released
// void keyReleased() {
//   if (keyCode == DOWN) {
//     dino.isCrouching = false;
//   }
// }

 /***************************** Private method ******************************************/
// Write score on screen
private void writeScore(int _dinoIndex) {
  fill(0);
  textAlign(LEFT);
  textSize(30);
  text("Score", 10, height - 1050);
  text(pop.dinoList.get(_dinoIndex).score, 10, height - 1020 + (_dinoIndex * 30));
}

private void setBackground() {
  // Set the background color
  background(255);
  // Set the color used to draw lines and borders around shapes
  stroke(0);
  strokeWeight(2);
  // Draw a line
  line(0, height - groundHeight - 30, width, height - groundHeight - 30);
}
