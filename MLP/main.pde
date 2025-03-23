Perceptron perceptron = new Perceptron();
Point[] points = new Point[100];

void setup() 
{
  size(600,600);
  
  for (int i = 0; i < points.length; i++) {
   points[i] = new Point(); 
  }
  
  float[] inputs = { -1, 0.5};
  perceptron.initialize(inputs.length);
  int result = perceptron.activationFunction(inputs);
  
  println(result);

  // Uncomment to run test
  //runTests()
}


void draw() { 
  background(255);
  stroke(0);
  line(0, 0, width, height);
  
  for (Point point : points) {
   point.show(); 
  }
  
  for (Point point : points) {
   float[] coordinate = { point.x, point.y};
   perceptron.train(coordinate, point.label); 
  }
} 


/* TESTS */  
void runTests() {
  runPerceptronTest();
}
