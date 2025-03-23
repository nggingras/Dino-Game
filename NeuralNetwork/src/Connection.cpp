// File: Connection.cpp
// Description: Definition of the Connection class for the Neural Network project.  
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-13  


#include "Connection.h"

Connection::Connection(Node* _fromNode, Node* _toNode, double _weight, bool _enabled) :
	m_pFromNode(_fromNode), 
	m_pToNode(_toNode), 
	m_dWeight(_weight), 
	m_bEnabled(_enabled)
{

}

Connection::~Connection()
{

}