Perceptron perceptron = new Perceptron();

void setup() 
{
  size(200,200);
  
  float[] inputs = { -1, 0.5};
  
  perceptron.initialize(inputs.length);
  int result = perceptron.activationFunction(inputs);
  
  println(result);

  // Uncomment to run test
  //runPerceptronTest();
}


void draw() { 

} 
