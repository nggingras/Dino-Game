// File: Node.cpp 
// Description: Definition of the Node class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-13  

#include "Node.h"

Node::Node(int _nodeId, double _bias) :
	m_iNodeId(_nodeId),
	m_dBias(_bias),
	m_dOutputValue(0)
{

}

Node::~Node() 
{
	
}

void Node::activate() 
{

	for (Connection* connection : m_vInputConnections)
	{
		if (connection->isEnabled()) {
			m_dOutputValue += connection->getFromNode()->getOutputValue() * connection->getWeight();
		}
	}

	m_dOutputValue += m_dBias;

	m_dOutputValue = sigmoid(m_dOutputValue);
}

double Node::sigmoid(double _x)
{
    return 1.0 / (1.0 + std::exp(-_x));
}

