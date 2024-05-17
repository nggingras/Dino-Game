class Dino {
  
  float posY = 0;
  float velY = 0;
  float gravity = 0.6;
  float speed = 5;

  int size = 20;
  
  int timerBetweenObstacles = 0;
  int minimumTimeBetweenObstacles = 30;
  int randomAdditionOfNewObstacles = floor(random(50));
  
  ArrayList<Obstacles> obstacles = new ArrayList<Obstacles>();
  
  Dino() {
    
  }
  
  void show() {
    fill(0);
    rectMode(CENTER);
    rect(50,height - 100 - (posY + size), size, size * 2);
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).show();
    }
  }

  void move() {
    speed += 0.001;
    
    timerBetweenObstacles += 1;
    if (timerBetweenObstacles > (minimumTimeBetweenObstacles + randomAdditionOfNewObstacles)) {
      addSmall();
      timerBetweenObstacles = 0;
      randomAdditionOfNewObstacles = floor(random(50));
    }
    
    posY += velY;  //<>//
    println(posY);
    
    if (posY > 0) {
      velY -= gravity;
    }
    else {
      velY = 0;
      posY = 0;
    }
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).move(speed);
      if (obstacles.get(i).posX < 0) {
        obstacles.remove(i);
      }
    }
  }
  
  void addSmall() {
    Obstacles temp = new Obstacles(0);
    obstacles.add(temp);
  }
}
