// File: Connection.cpp
// Description: Definition of the neuralNetwork class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-23  

#include <unordered_map>
#include <queue>
#include <algorithm>

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
	
	// Create connections between layers
	createConnections();
}

neuralNetwork::~neuralNetwork()
{
	// Delete all connections first
	for (Node* node : m_vNodes)
	{
		for (const Connection* conn : node->getInputConnections())
		{
			delete conn;
		}
	}
	
	// Then delete all nodes
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

void neuralNetwork::createConnections()
{
	// Create connections from input to hidden layer
	for (Node* inputNode : m_vInputNodes)
	{
		for (Node* hiddenNode : m_vHiddenNodes)
		{
			double randomWeight = ((rand() % 2000) / 1000.0) - 1.0; // Weight in range [-1, 1]
			Connection* conn = new Connection(inputNode, hiddenNode, randomWeight);
			hiddenNode->addInputConnection(conn);
		}
	}
	
	// Create connections from hidden to output layer
	for (Node* hiddenNode : m_vHiddenNodes)
	{
		for (Node* outputNode : m_vOutputNodes)
		{
			double randomWeight = ((rand() % 2000) / 1000.0) - 1.0; // Weight in range [-1, 1]
			Connection* conn = new Connection(hiddenNode, outputNode, randomWeight);
			outputNode->addInputConnection(conn);
		}
	}
}

void neuralNetwork::feedForward(const std::vector<double>& _inputs)
{
	// Set input values
	for (size_t i = 0; i < _inputs.size() && i < m_vInputNodes.size(); ++i)
	{
		m_vInputNodes[i]->setOutputValue(_inputs[i]);
	}

	// Get topological order of nodes
	std::vector<Node*> sortedNodes = topologicalSort();

	// Process nodes in topological order
	for (Node* node : sortedNodes)
	{
		if (!node->isInputNode())
		{
			node->activate();
		}
	}
}

std::vector<double> neuralNetwork::getOutputs() const
{
	std::vector<double> outputs;
	outputs.reserve(m_vOutputNodes.size());
	
	for (const Node* node : m_vOutputNodes)
	{
		outputs.push_back(node->getOutputValue());
	}
	
	return outputs;
}

std::vector<Node*> neuralNetwork::topologicalSort()
{
	// NEAT Algorithm requires node to be computed in the
	// right order.
	std::vector<Node*> sortedNodes;
	std::unordered_map<Node*, int> inDegree;
	std::queue<Node*> zeroInDegreeQueue;

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
			if (connection->isEnabled())
			{
				inDegree[node]++;
			}
		}
	}

	// Add all nodes with zero in-degree to queue
	for (auto& node : m_vNodes)
	{
		if (inDegree[node] == 0)
		{
			zeroInDegreeQueue.push(node);
		}
	}

	// Process queue
	while (!zeroInDegreeQueue.empty())
	{
		Node* current = zeroInDegreeQueue.front();
		zeroInDegreeQueue.pop();
		sortedNodes.push_back(current);

		// Find all nodes that current connects to and reduce their in-degree
		for (auto& node : m_vNodes)
		{
			const auto& inputConnections = node->getInputConnections();
			for (auto& connection : inputConnections)
			{
				if (connection->isEnabled() && connection->getFromNode() == current)
				{
					inDegree[node]--;
					if (inDegree[node] == 0)
					{
						zeroInDegreeQueue.push(node);
					}
				}
			}
		}
	}

	// Check for cycles (if sortedNodes.size() != m_vNodes.size())
	if (sortedNodes.size() != m_vNodes.size())
	{
		// Handle cycles by adding remaining nodes at the end
		for (auto& node : m_vNodes)
		{
			if (std::find(sortedNodes.begin(), sortedNodes.end(), node) == sortedNodes.end())
			{
				sortedNodes.push_back(node);
			}
		}
	}

	return sortedNodes;
}