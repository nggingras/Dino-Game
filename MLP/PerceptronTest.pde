void runPerceptronTest() {
  testInitialize();
  testActivationFunction();
  println("All tests passed.");
}

void testInitialize() {
  Perceptron perceptron = new Perceptron();
  perceptron.initialize(3);
  
  assertTrue(perceptron.mNumberOfInputs == 3, "Initialization failed: Incorrect number of inputs.");
  assertTrue(perceptron.mWeights.length == 3, "Initialization failed: Incorrect weights array length.");
  
  for (int i = 0; i < perceptron.mWeights.length; i++) {
    assertTrue(perceptron.mWeights[i] >= -1 && perceptron.mWeights[i] <= 1, "Initialization failed: Weight out of range.");
  }
}

void testActivationFunction() {
  Perceptron perceptron = new Perceptron();
  perceptron.initialize(2);
  
  float[] inputs = {1, 1};
  perceptron.mWeights[0] = 0.5;
  perceptron.mWeights[1] = 0.5;
  
  int output = perceptron.activationFunction(inputs);
  assertTrue(output == 1, "Activation function failed: Expected 1.");
  
  perceptron.mWeights[0] = -0.5;
  perceptron.mWeights[1] = -0.5;
  
  output = perceptron.activationFunction(inputs);
  assertTrue(output == -1, "Activation function failed: Expected -1.");
}

void assertTrue(boolean condition, String message) {
  if (!condition) {
    println(message);
    exit();
  }
}
