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

	void feedForward(const std::vector<double>& _inputs);
	std::vector<double> getOutputs() const;
	
	void addInputNode(Node* _node);
	void addHiddenNode(Node* _node);
	void addOutputNode(Node* _node);

	void createConnections(); // Create connections between all layers

	const std::vector<Node*>& getInputNodes() const { return m_vInputNodes; }
	const std::vector<Node*>& getHiddenNodes() const { return m_vHiddenNodes; }
	const std::vector<Node*>& getOutputNodes() const { return m_vOutputNodes; }

private:
	std::vector<Node*>	m_vNodes;
	std::vector<Node*>	m_vInputNodes;
	std::vector<Node*>  m_vHiddenNodes;
	std::vector<Node*>	m_vOutputNodes;

	std::vector<Node*> topologicalSort();

	// Friend class to allow Genome to access private members
	friend class Genome;
};




#endif // NEURAL_NETWORK_H
