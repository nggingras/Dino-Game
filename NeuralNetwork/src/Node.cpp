// File: Node.cpp 
// Description: Definition of the Node class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-13  

#include "Node.h"

Node::Node(int _nodeId, bool _isInput, double _bias) :
	m_iNodeId(_nodeId),
	m_dBias(_bias),
	m_dOutputValue(0),
	m_bIsInput(_isInput)
{

}

Node::~Node() 
{
	
}

void Node::activate() 
{
	// If no connections, then the node is an input node
	if (isInputNode()) {
		return;  // Input nodes already have values
	}

	// Reset output value before calculating
	m_dOutputValue = 0.0;

	for (Connection* connection : m_vInputConnections)
	{
		if (connection->isEnabled()) {
			m_dOutputValue += connection->getFromNode()->getOutputValue() * connection->getWeight();
		}
	}

	m_dOutputValue += m_dBias;

	// Activation function
	m_dOutputValue = sigmoid(m_dOutputValue);
}

double Node::sigmoid(const double _x)
{
    return 1.0 / (1.0 + std::exp(-_x));
}

