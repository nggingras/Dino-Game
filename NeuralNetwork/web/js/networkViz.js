// Neural Network Visualization using HTML5 Canvas
const INPUT_LABELS = ['dinoY', 'dinoVelocity', 'obstacleX', 'obstacleHeight'];
const OUTPUT_LABELS = ['jump', 'crouch'];

class NetworkVisualizer {
    constructor(containerId) {
        this.container = document.querySelector(containerId);
        this.width = 400;
        this.height = 250;
        
        // Create canvas for visualization
        this.canvas = document.createElement('canvas');
        this.canvas.width = this.width;
        this.canvas.height = this.height;
        this.canvas.style.width = '100%';
        this.canvas.style.height = '100%';
        this.ctx = this.canvas.getContext('2d');
        
        this.container.appendChild(this.canvas);
        
        this.network = null;
        this.lastInputs = null;
        this.lastOutputs = null;
    }
    
    // Update the network visualization with new neural network data
    updateNetwork(network) {
        if (!network) return;
        
        this.network = network;
        this.draw();
    }
    
    // Draw the neural network
    draw() {
        if (!this.network) return;
        
        // Clear canvas
        this.ctx.clearRect(0, 0, this.width, this.height);
        
        // Set up drawing parameters
        const margin = 40;
        const nodeRadius = 15;
        const leftX = margin;
        const rightX = this.width - margin;
        
        // Calculate positions for input nodes
        const inputNodes = [];
        for (let i = 0; i < this.network.numInputs; i++) {
            const y = (this.height - 2 * margin) * (i + 1) / (this.network.numInputs + 1) + margin;
            inputNodes.push({
                x: leftX,
                y: y,
                type: 'input',
                index: i,
                label: INPUT_LABELS[i] || `input${i}`
            });
        }
        
        // Calculate positions for output nodes
        const outputNodes = [];
        for (let i = 0; i < this.network.numOutputs; i++) {
            const y = (this.height - 2 * margin) * (i + 1) / (this.network.numOutputs + 1) + margin;
            outputNodes.push({
                x: rightX,
                y: y,
                type: 'output',
                index: i,
                label: OUTPUT_LABELS[i] || `output${i}`
            });
        }
        
        // Calculate positions for hidden nodes
        const hiddenNodes = [];
        if (this.network.nodes) {
            const hiddenNetworkNodes = this.network.nodes.filter(node => node.type === 'hidden');
            const maxLayer = hiddenNetworkNodes.length > 0 ? Math.max(...hiddenNetworkNodes.map(n => n.layer)) : 0;
            
            hiddenNetworkNodes.forEach((node, index) => {
                const x = leftX + (rightX - leftX) * (node.layer / (maxLayer + 1));
                const y = (this.height - 2 * margin) * (index + 1) / (hiddenNetworkNodes.length + 1) + margin;
                hiddenNodes.push({
                    x: x,
                    y: y,
                    type: 'hidden',
                    index: index,
                    id: node.id
                });
            });
        }
        
        const allNodes = [...inputNodes, ...hiddenNodes, ...outputNodes];
        
        // Draw connections
        if (this.network.connections) {
            this.network.connections.forEach(conn => {
                if (!conn.enabled) return;
                
                const sourceNode = this.findNodeByGenomeId(allNodes, conn.fromNode);
                const targetNode = this.findNodeByGenomeId(allNodes, conn.toNode);
                
                if (sourceNode && targetNode) {
                    this.drawConnection(sourceNode, targetNode, conn.weight);
                }
            });
        }
        
        // Draw nodes
        allNodes.forEach(node => {
            this.drawNode(node);
        });
        
        // Draw labels
        allNodes.forEach(node => {
            if (node.type === 'input' || node.type === 'output') {
                this.drawLabel(node);
            }
        });
    }
    
    // Find node by genome ID
    findNodeByGenomeId(nodes, genomeId) {
        if (genomeId < this.network.numInputs) {
            // Input node
            return nodes.find(node => node.type === 'input' && node.index === genomeId);
        } else if (genomeId < this.network.numInputs + this.network.numOutputs) {
            // Output node
            const outputIndex = genomeId - this.network.numInputs;
            return nodes.find(node => node.type === 'output' && node.index === outputIndex);
        } else {
            // Hidden node
            return nodes.find(node => node.type === 'hidden' && node.id === genomeId);
        }
    }
    
    // Draw a connection between two nodes
    drawConnection(sourceNode, targetNode, weight) {
        this.ctx.beginPath();
        this.ctx.moveTo(sourceNode.x, sourceNode.y);
        this.ctx.lineTo(targetNode.x, targetNode.y);
        
        // Color based on weight
        if (weight > 0) {
            this.ctx.strokeStyle = `rgba(76, 175, 80, ${Math.min(1, Math.abs(weight))})`;
        } else {
            this.ctx.strokeStyle = `rgba(244, 67, 54, ${Math.min(1, Math.abs(weight))})`;
        }
        
        this.ctx.lineWidth = Math.max(1, Math.abs(weight) * 3);
        this.ctx.stroke();
    }
    
    // Draw a node
    drawNode(node) {
        this.ctx.beginPath();
        this.ctx.arc(node.x, node.y, 15, 0, 2 * Math.PI);
        
        // Color based on type and activity
        let fillColor = this.getNodeColor(node.type);
        let strokeWidth = 2;
        
        // Highlight active nodes
        if (node.type === 'input' && this.lastInputs) {
            const intensity = Math.abs(this.lastInputs[node.index] || 0);
            fillColor = `rgba(76, 175, 80, ${0.3 + 0.7 * intensity})`;
        } else if (node.type === 'output' && this.lastOutputs) {
            const value = this.lastOutputs[node.index] || 0;
            if (value > 0.5) {
                fillColor = '#FFD700';
                strokeWidth = 4;
            }
        }
        
        this.ctx.fillStyle = fillColor;
        this.ctx.fill();
        this.ctx.strokeStyle = '#333';
        this.ctx.lineWidth = strokeWidth;
        this.ctx.stroke();
        
        // Draw node ID for hidden nodes
        if (node.type === 'hidden') {
            this.ctx.fillStyle = '#333';
            this.ctx.font = '12px Arial';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';
            this.ctx.fillText(node.id.toString(), node.x, node.y);
        }
    }
    
    // Draw label for input/output nodes
    drawLabel(node) {
        let labelText = node.label;
        let value = '';
        
        if (node.type === 'input' && this.lastInputs) {
            value = `: ${this.lastInputs[node.index]?.toFixed(2) || '0.00'}`;
        } else if (node.type === 'output' && this.lastOutputs) {
            value = `: ${this.lastOutputs[node.index]?.toFixed(2) || '0.00'}`;
        }
        
        const fullText = labelText + value;
        
        this.ctx.fillStyle = '#333';
        this.ctx.font = 'bold 12px Arial';
        this.ctx.textBaseline = 'middle';
        
        if (node.type === 'input') {
            this.ctx.textAlign = 'right';
            this.ctx.fillText(fullText, node.x - 20, node.y);
        } else {
            this.ctx.textAlign = 'left';
            this.ctx.fillText(fullText, node.x + 20, node.y);
        }
    }
    
    // Get node color based on type
    getNodeColor(type) {
        switch (type) {
            case 'input': return '#4CAF50';  // Green
            case 'hidden': return '#2196F3'; // Blue
            case 'output': return '#FF9800'; // Orange
            default: return '#9E9E9E';       // Gray
        }
    }
    
    // Update with real-time data
    updateRealTime(inputs, outputs) {
        this.lastInputs = inputs;
        this.lastOutputs = outputs;
        this.draw(); // Redraw with updated values
    }
    
    // Clear visualization
    clear() {
        if (this.ctx) {
            this.ctx.clearRect(0, 0, this.width, this.height);
        }
    }
    
    // Resize visualization
    resize(width, height) {
        this.width = width;
        this.height = height;
        this.canvas.width = width;
        this.canvas.height = height;
        this.draw();
    }
}

// Evolution statistics visualization using HTML5 Canvas
class EvolutionStats {
    constructor(containerId) {
        this.container = document.querySelector(containerId);
        this.width = 400;
        this.height = 200;
        this.margin = { top: 20, right: 20, bottom: 30, left: 40 };
        
        // Create canvas for visualization
        this.canvas = document.createElement('canvas');
        this.canvas.width = this.width;
        this.canvas.height = this.height;
        this.canvas.style.width = '100%';
        this.canvas.style.height = '100%';
        this.ctx = this.canvas.getContext('2d');
        
        this.container.appendChild(this.canvas);
        
        this.data = [];
        this.maxGenerations = 100;
    }
    
    // Add fitness data point
    addFitness(generation, bestFitness, avgFitness) {
        this.data.push({
            generation: generation,
            best: bestFitness,
            average: avgFitness
        });
        
        // Keep only recent data
        if (this.data.length > this.maxGenerations) {
            this.data.shift();
        }
        
        this.updateChart();
    }
    
    // Update the chart
    updateChart() {
        if (this.data.length === 0) return;
        
        // Clear canvas
        this.ctx.clearRect(0, 0, this.width, this.height);
        
        // Calculate scales
        const maxGeneration = Math.max(...this.data.map(d => d.generation));
        const maxFitness = Math.max(...this.data.map(d => Math.max(d.best, d.average)));
        
        const xScale = (value) => this.margin.left + (this.width - this.margin.left - this.margin.right) * (value / maxGeneration);
        const yScale = (value) => this.height - this.margin.bottom - (this.height - this.margin.top - this.margin.bottom) * (value / maxFitness);
        
        // Draw axes
        this.ctx.strokeStyle = '#333';
        this.ctx.lineWidth = 1;
        
        // X-axis
        this.ctx.beginPath();
        this.ctx.moveTo(this.margin.left, this.height - this.margin.bottom);
        this.ctx.lineTo(this.width - this.margin.right, this.height - this.margin.bottom);
        this.ctx.stroke();
        
        // Y-axis
        this.ctx.beginPath();
        this.ctx.moveTo(this.margin.left, this.margin.top);
        this.ctx.lineTo(this.margin.left, this.height - this.margin.bottom);
        this.ctx.stroke();
        
        // Draw best fitness line
        if (this.data.length > 1) {
            this.ctx.strokeStyle = '#4CAF50';
            this.ctx.lineWidth = 2;
            this.ctx.beginPath();
            this.data.forEach((d, i) => {
                const x = xScale(d.generation);
                const y = yScale(d.best);
                if (i === 0) {
                    this.ctx.moveTo(x, y);
                } else {
                    this.ctx.lineTo(x, y);
                }
            });
            this.ctx.stroke();
            
            // Draw average fitness line
            this.ctx.strokeStyle = '#2196F3';
            this.ctx.lineWidth = 2;
            this.ctx.beginPath();
            this.data.forEach((d, i) => {
                const x = xScale(d.generation);
                const y = yScale(d.average);
                if (i === 0) {
                    this.ctx.moveTo(x, y);
                } else {
                    this.ctx.lineTo(x, y);
                }
            });
            this.ctx.stroke();
        }
        
        // Draw legend
        this.ctx.font = '12px Arial';
        this.ctx.textAlign = 'left';
        
        // Best fitness legend
        this.ctx.strokeStyle = '#4CAF50';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.moveTo(this.width - 100, 30);
        this.ctx.lineTo(this.width - 80, 30);
        this.ctx.stroke();
        
        this.ctx.fillStyle = '#333';
        this.ctx.fillText('Best', this.width - 75, 34);
        
        // Average fitness legend
        this.ctx.strokeStyle = '#2196F3';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.moveTo(this.width - 100, 50);
        this.ctx.lineTo(this.width - 80, 50);
        this.ctx.stroke();
        
        this.ctx.fillStyle = '#333';
        this.ctx.fillText('Average', this.width - 75, 54);
    }
    
    // Clear chart
    clear() {
        if (this.ctx) {
            this.ctx.clearRect(0, 0, this.width, this.height);
        }
        this.data = [];
    }
} 