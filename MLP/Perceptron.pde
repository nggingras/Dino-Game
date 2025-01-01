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
  mNumberOfInputs = _numberOfInputs;
  mWeights = new float[_numberOfInputs];
  
  for (int i = 0; i < _numberOfInputs; i++) {
    mWeights[i] = random(-1, 1);
  }
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
  return (sum > 0) ? 1 : -1;
  }
}
