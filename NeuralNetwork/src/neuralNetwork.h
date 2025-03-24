// File: neuralNetwork.cpp
// Description: Definition of the neuralNetwork class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-23  


#ifndef NEURAL_NETWORK_H
#define NEURAL_NETWORK_H

#include <vector>
#include "Node.h"

class neuralNetwork
{
public:
	neuralNetwork(int _numInputNodes, int _numHiddenNodes, int _numOutputNodes);
	~neuralNetwork();

	//void feedForward();
	void addInputNode(Node* _node);
	void addHiddenNode(Node* _node);
	void addOutputNode(Node* _node);

private:
	std::vector<Node*>	m_vNodes;
	std::vector<Node*>	m_vInputNodes;
	std::vector<Node*>  m_vHiddenNodes;
	std::vector<Node*>	m_vOutputNodes;

	std::vector<Node*> topologicalSort();
};




#endif // NEURAL_NETWORK_H
