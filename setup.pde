Dino dino;

//images
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

void setup() {
  size(800,400);
  
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
  
  dino = new Dino();  
  dino.addSmall();
}

void draw() {
 background(255);
 stroke(0);
 line(0, height - 100, width, height - 100);
 dino.move(); //<>//
 dino.show();

}

void keyPressed() {
  switch (key) {
  case ' ':
    if (dino.posY == 0) {
      dino.velY = 10;
    }
  }
}
