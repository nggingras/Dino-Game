// Neural Network implementation for running NEAT genomes
class NEATNetwork {
    constructor(genomeData) {
        this.genomeData = genomeData;
        this.nodes = new Map();
        this.connections = [];
        this.inputs = [];
        this.outputs = [];
        
        this.buildNetwork();
    }
    
    // Build the network from genome data
    buildNetwork() {
        // Create nodes
        for (const nodeData of this.genomeData.nodes) {
            this.nodes.set(nodeData.id, {
                id: nodeData.id,
                layer: nodeData.layer,
                type: nodeData.type,
                value: 0,
                activated: false
            });
        }
        
        // Create connections
        for (const connData of this.genomeData.connections) {
            if (connData.enabled) {
                this.connections.push({
                    fromNode: connData.fromNode,
                    toNode: connData.toNode,
                    weight: connData.weight
                });
            }
        }
        
        // Sort nodes by layer for proper feedforward
        this.sortedNodes = Array.from(this.nodes.values()).sort((a, b) => a.layer - b.layer);
    }
    
    // Feed forward through the network
    feedForward(inputs) {
        // Reset all node values
        for (const node of this.nodes.values()) {
            node.value = 0;
            node.activated = false;
        }
        
        // Set input values
        const inputNodes = this.sortedNodes.filter(node => node.type === 'input');
        for (let i = 0; i < Math.min(inputs.length, inputNodes.length); i++) {
            inputNodes[i].value = inputs[i];
            inputNodes[i].activated = true;
        }
        
        // Process nodes layer by layer
        for (const node of this.sortedNodes) {
            if (node.type === 'input') continue; // Inputs already set
            
            // Calculate node value from incoming connections
            let sum = 0;
            for (const conn of this.connections) {
                if (conn.toNode === node.id) {
                    const fromNode = this.nodes.get(conn.fromNode);
                    if (fromNode && fromNode.activated) {
                        sum += fromNode.value * conn.weight;
                    }
                }
            }
            
            // Apply activation function
            node.value = this.activationFunction(sum);
            node.activated = true;
        }
        
        // Get output values
        const outputNodes = this.sortedNodes.filter(node => node.type === 'output');
        this.outputs = outputNodes.map(node => node.value);
        
        return this.outputs;
    }
    
    // Activation function (tanh)
    activationFunction(x) {
        return Math.tanh(x);
    }
    
    // Get outputs
    getOutputs() {
        return this.outputs || [0, 0];
    }
    
    // Get network structure for visualization
    getNetworkStructure() {
        return {
            numInputs: this.genomeData.numInputs,
            numOutputs: this.genomeData.numOutputs,
            nodes: this.genomeData.nodes,
            connections: this.genomeData.connections
        };
    }
} 