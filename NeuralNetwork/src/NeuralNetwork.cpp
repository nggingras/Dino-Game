// File: Connection.cpp
// Description: Definition of the neuralNetwork class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-23  

#include <unordered_map>

#include "neuralNetwork.h"

neuralNetwork::neuralNetwork(int _numInputNodes, int _numHiddenNodes, int _numOutputNodes)
{
	m_vNodes.reserve(_numInputNodes + _numHiddenNodes + _numOutputNodes);
	m_vInputNodes.reserve(_numInputNodes);
	m_vHiddenNodes.reserve(_numHiddenNodes);
	m_vOutputNodes.reserve(_numOutputNodes);

	// Create input nodes
	for (int i = 0; i < _numInputNodes; ++i)
	{
		Node* inputNode = new Node(i, true, 0.0);
		addInputNode(inputNode);
	}
	// Create hidden nodes
	for (int i = 0; i < _numHiddenNodes; ++i)
	{
		double randomBias = ((rand() % 2000) / 1000.0) - 1.0; // Bias in range [-1, 1]

		Node* hiddenNode = new Node(i + _numInputNodes, false, randomBias);
		addHiddenNode(hiddenNode);
	}
	// Create output nodes
	for (int i = 0; i < _numOutputNodes; ++i)
	{
		double randomBias = ((rand() % 2000) / 1000.0) - 1.0; // Bias in range [-1, 1]

		Node* outputNode = new Node(i + _numInputNodes + _numHiddenNodes, false, randomBias);
		addOutputNode(outputNode);
	}
}

neuralNetwork::~neuralNetwork()
{
	for (Node* node : m_vNodes)
	{
		delete node;
	}
}

void neuralNetwork::addInputNode(Node* _node)
{
	m_vInputNodes.push_back(_node);
	m_vNodes.push_back(_node);
}

void neuralNetwork::addHiddenNode(Node* _node)
{
	m_vHiddenNodes.push_back(_node);
	m_vNodes.push_back(_node);
}

void neuralNetwork::addOutputNode(Node* _node)
{
	m_vOutputNodes.push_back(_node);
	m_vNodes.push_back(_node);
}

//void neuralNetwork::feedForward()
//{
//
//
//}

std::vector<Node*> neuralNetwork::topologicalSort()
{
	// NEAT Algorithm requires node to be computed in the
	// right order.
	std::vector<Node*> sortedNodes;
	std::unordered_map<Node*, int> inDegree;

	// Initialize inDegree to 0 incoming connections
	// for all nodes.
	for (auto& node : m_vNodes)
	{
		inDegree[node] = 0;
	}

	// Calculate inDegree for all nodes.
	for (auto& node : m_vNodes)
	{
		const auto& inputConnections = node->getInputConnections();
		for (auto& connection : inputConnections)
		{
			inDegree[node]++;
		}
	}



	return sortedNodes;
}