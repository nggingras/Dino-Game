// File: Connection.h
// Description: Definition of the Connection class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-13  


#ifndef CONNECTION_H
#define CONNECTION_H

class Node; 

class Connection {
public:
	Connection(Node* _fromNode, Node* _toNode, double _weight, bool _enable = 1);
	~Connection();

	Node*	getFromNode()	const	{ return m_pFromNode; }
	Node*	getToNode()		const 	{ return m_pToNode; }
	double	getWeight()		const 	{ return m_dWeight; }
	bool	isEnabled()		const	{ return m_bEnabled; }

    
private:
	Node*	m_pFromNode;
	Node*	m_pToNode;

	double	m_dWeight;

	bool	m_bEnabled;


};

#endif // CONNECTION_H