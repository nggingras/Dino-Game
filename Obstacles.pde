class Obstacles {
  float posX;
  int w;
  int h;
  int type;
  
  //Should be an enum if I knew how
  final int eSmallCactus = 0;
  final int eBigCactus = 1;
  final int eBird = 2;
 
  Obstacles(int _type) {
    posX = width;
    type = _type;
    
    switch (type) {
      case eSmallCactus:
        w = 40;
        h = 80;
        break;
      case eBigCactus:
        w = 60;
        h = 120;
        break;
      //case bird:
      //  w = 120;
      //  h = 80;
      //  break;
    }
  }
  
  void show() {
    fill(0);
    rectMode(CENTER);
   //rect(posX, height - 100 - h/2, w, h); 
   switch(type) {
     case eSmallCactus:
       image(smallCactus, posX, height - 100 - h/2, w, h);
       break;
     //case bigCactus:
     //  image..
     //  break;
     //case bird:
     //  image...
     //  break;
   }
  }
  
  void move(float speed) {
   posX -= speed;
  }
}
