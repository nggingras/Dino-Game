// Define a class to represent a genotype.
class Genotype {

    ArrayList<ConnectionGene> connections = new ArrayList<ConnectionGene>();
    ArrayList<NodeGene> nodes             = new ArrayList<NodeGene>();
    
    float fitness = 0;
    int species = 0;
    
    // Constructor for creating a basic genotype with input and output nodes
    Genotype(int numInputs, int numOutputs) {
        // Create input nodes
        for (int i = 0; i < numInputs; i++) {
            nodes.add(new NodeGene(i, NodeGene.INPUT));
        }
        
        // Create output nodes
        for (int i = numInputs; i < numInputs + numOutputs; i++) {
            nodes.add(new NodeGene(i, NodeGene.OUTPUT));
        }
        
        // Create initial connections between all inputs and outputs
        int innovation = 0;
        for (int i = 0; i < numInputs; i++) {
            for (int j = numInputs; j < numInputs + numOutputs; j++) {
                connections.add(new ConnectionGene(nodes.get(i), nodes.get(j), innovation++, random(-1, 1)));
            }
        }
    }
    
    // Copy constructor
    Genotype(Genotype parent) {
        fitness = 0;
        species = parent.species;
        
        // Copy nodes
        for (NodeGene node : parent.nodes) {
            nodes.add(new NodeGene(node));
        }
        
        // Copy connections
        for (ConnectionGene conn : parent.connections) {
            connections.add(new ConnectionGene(conn));
        }
    }
    
    // Evaluate the neural network with given inputs
    float[] feedForward(float[] inputs) {
        // Reset all node values
        HashMap<Integer, Float> nodeValues = new HashMap<Integer, Float>();
        
        // Set input values
        for (int i = 0; i < inputs.length && i < nodes.size(); i++) {
            if (nodes.get(i).m_type == nodes.get(i).INPUT) {
                nodeValues.put(nodes.get(i).m_id, inputs[i]);
            }
        }
        
        // Calculate values for hidden and output nodes
        // Sort nodes by type and ID to ensure proper calculation order
        ArrayList<NodeGene> sortedNodes = new ArrayList<NodeGene>(nodes);
        // Simple sort by type first, then by ID
        for (int i = 0; i < sortedNodes.size() - 1; i++) {
            for (int j = i + 1; j < sortedNodes.size(); j++) {
                NodeGene a = sortedNodes.get(i);
                NodeGene b = sortedNodes.get(j);
                if (a.m_type > b.m_type || (a.m_type == b.m_type && a.m_id > b.m_id)) {
                    sortedNodes.set(i, b);
                    sortedNodes.set(j, a);
                }
            }
        }
        
        for (NodeGene node : sortedNodes) {
            if (node.m_type != node.INPUT && !nodeValues.containsKey(node.m_id)) {
                float sum = 0;
                for (ConnectionGene conn : connections) {
                    if (conn.m_outNode.m_id == node.m_id && conn.m_enabled && nodeValues.containsKey(conn.m_inNode.m_id)) {
                        sum += nodeValues.get(conn.m_inNode.m_id) * conn.m_weight;
                    }
                }
                nodeValues.put(node.m_id, (float)Math.tanh(sum)); // Use tanh activation function
            }
        }
        
        // Collect output values
        ArrayList<Float> outputs = new ArrayList<Float>();
        for (NodeGene node : nodes) {
            if (node.m_type == node.OUTPUT && nodeValues.containsKey(node.m_id)) {
                outputs.add(nodeValues.get(node.m_id));
            }
        }
        
        float[] result = new float[outputs.size()];
        for (int i = 0; i < outputs.size(); i++) {
            result[i] = outputs.get(i);
        }
        
        return result;
    }
    
    // Mutate the genotype
    void mutate() {
        // Weight mutation
        for (ConnectionGene conn : connections) {
            conn.mutateWeight();
        }
        
        // Add connection mutation (5% chance)
        if (random(1) < 0.05) {
            addConnectionMutation();
        }
        
        // Add node mutation (3% chance)  
        if (random(1) < 0.03) {
            addNodeMutation();
        }
    }
    
    // Add a new connection between two nodes
    void addConnectionMutation() {
        if (nodes.size() < 2) return;
        
        NodeGene inNode = nodes.get((int)random(nodes.size()));
        NodeGene outNode = nodes.get((int)random(nodes.size()));
        
        // Ensure we don't create loops or invalid connections
        if (inNode.m_id == outNode.m_id || inNode.m_type == inNode.OUTPUT || outNode.m_type == outNode.INPUT) {
            return;
        }
        
        // Check if connection already exists
        for (ConnectionGene conn : connections) {
            if (conn.m_inNode.m_id == inNode.m_id && conn.m_outNode.m_id == outNode.m_id) {
                return;
            }
        }
        
        // Add new connection
        connections.add(new ConnectionGene(inNode, outNode, connections.size(), random(-1, 1)));
    }
    
    // Add a new node by splitting an existing connection
    void addNodeMutation() {
        if (connections.isEmpty()) return;
        
        ConnectionGene oldConn = connections.get((int)random(connections.size()));
        oldConn.m_enabled = false;
        
        // Create new node
        int newNodeId = nodes.size();
        NodeGene newNode = new NodeGene(newNodeId, newNode.HIDDEN);
        nodes.add(newNode);
        
        // Create two new connections
        connections.add(new ConnectionGene(oldConn.m_inNode, newNode, connections.size(), 1.0));
        connections.add(new ConnectionGene(newNode, oldConn.m_outNode, connections.size(), (float)oldConn.m_weight));
    }
}