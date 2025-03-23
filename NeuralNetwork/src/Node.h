// File: Node.h  
// Description: Definition of the Node class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-13  

#ifndef NODE_H  
#define NODE_H  

#include <vector>
#include <cmath> 

#include "Connection.h"

class Node {  
public:  
	Node(int _nodeId, double _bias = 0.0);
	~Node();  

	void activate();

	int		getNodeId()					const	{ return m_iNodeId; }
	size_t	getNumInputConnections()	const	{ return m_vInputConnections.size(); }
	double	getBias()					const	{ return m_dBias; }
	double	getOutputValue()			const	{ return m_dOutputValue; }

	void	addInputConnection(Connection* _connection) { m_vInputConnections.push_back(_connection); }

	// For testing purposes
	void	setOutputValue(double _outputValue)			{ m_dOutputValue = _outputValue; }

private:
	static double sigmoid(double _x);

public:
	//

private:  
	int m_iNodeId;
	
	double m_dBias;
	double m_dOutputValue;

	std::vector<Connection*> m_vInputConnections;

};  

#endif // NODE_H