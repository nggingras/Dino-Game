/**
 * Perceptron class represents a simple neural network unit.
 * It contains methods to initialize the perceptron with a specified number of inputs
 * and to compute the output using an activation function.
 */
class Perceptron {
  
  /**
   * Number of inputs to the perceptron.
   */
  int mNumberOfInputs = 0;
 
  /**
   * Learning rate of the perceptron.
   */
  float learningRate = 0;
  
  /**
   * Array of weights for each input.
   */
  float[] mWeights;
  
  /**
   * Default constructor for the Perceptron class.
   */
  Perceptron() {}
  
  /**
   * Initializes the perceptron with a specified number of inputs.
   * Randomly assigns weights to each input between -1 and 1.
   *
   * @param _numberOfInputs The number of inputs for the perceptron.
   */
  void initialize(int _numberOfInputs) {
    
  learningRate = 0.1;
  mNumberOfInputs = _numberOfInputs;
  mWeights = new float[_numberOfInputs /*+ 1*/];
  
  for (int i = 0; i < _numberOfInputs; i++) {
    mWeights[i] = random(-1, 1);
  }
  
  /* Configure Bias to 1 */
  //mWeights[_numberOfInputs] = 1;
  }
  
  /**
   * Computes the output of the perceptron using the activation function.
   * The activation function returns 1 if the weighted sum of inputs is greater than 0,
   * otherwise it returns -1.
   *
   * @param _inputs Array of input values.
   * @return The output of the perceptron (1 or -1).
   */
  int activationFunction(float[] _inputs) {
    
  float sum = 0;
  for (int i = 0; i < mNumberOfInputs; i++) {
    sum += _inputs[i] * mWeights[i];
  }
  //sum += mWeights[mNumberOfInputs];
  
  return (sum > 0) ? 1 : -1;
  }
  
  void train(float[] _inputs, int _expectedResult) {
    
    float error = 0;
    
    error = _expectedResult - activationFunction(_inputs); 
    for (int i = 0; i < (mWeights.length); i++) {
      mWeights[i] += error * _inputs[i] * learningRate;
    }
  }
}
