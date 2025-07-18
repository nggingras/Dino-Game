// Neural Network Visualization using D3.js
class NetworkVisualizer {
    constructor(containerId) {
        this.container = d3.select(containerId);
        this.width = 400;
        this.height = 300;
        this.margin = { top: 20, right: 20, bottom: 20, left: 20 };
        
        this.svg = this.container
            .append('svg')
            .attr('width', this.width)
            .attr('height', this.height);
            
        this.simulation = null;
        this.nodes = [];
        this.links = [];
    }
    
    // Update the network visualization with new neural network data
    updateNetwork(network) {
        if (!network) return;
        
        // Clear previous visualization
        this.svg.selectAll('*').remove();
        
        // Convert network to D3 format
        this.convertNetworkToD3(network);
        
        // Create the visualization
        this.createVisualization();
    }
    
    // Convert neural network to D3.js format
    convertNetworkToD3(network) {
        this.nodes = [];
        this.links = [];
        
        // Add input nodes
        for (let i = 0; i < network.numInputs; i++) {
            this.nodes.push({
                id: `input_${i}`,
                type: 'input',
                layer: 0,
                x: 50,
                y: (this.height - 100) * (i + 1) / (network.numInputs + 1) + 50
            });
        }
        
        // Add hidden nodes
        if (network.nodes) {
            const hiddenNodes = network.nodes.filter(node => 
                node.layer > 0 && node.layer < network.numLayers - 1
            );
            
            hiddenNodes.forEach((node, index) => {
                this.nodes.push({
                    id: `hidden_${node.id}`,
                    type: 'hidden',
                    layer: node.layer,
                    x: 200 + (node.layer - 1) * 100,
                    y: (this.height - 100) * (index + 1) / (hiddenNodes.length + 1) + 50
                });
            });
        }
        
        // Add output nodes
        for (let i = 0; i < network.numOutputs; i++) {
            this.nodes.push({
                id: `output_${i}`,
                type: 'output',
                layer: network.numLayers - 1,
                x: this.width - 50,
                y: (this.height - 100) * (i + 1) / (network.numOutputs + 1) + 50
            });
        }
        
        // Add connections
        if (network.connections) {
            network.connections.forEach(conn => {
                if (conn.enabled) {
                    this.links.push({
                        source: this.findNodeById(conn.fromNode),
                        target: this.findNodeById(conn.toNode),
                        weight: conn.weight,
                        enabled: conn.enabled
                    });
                }
            });
        }
    }
    
    // Find node by ID
    findNodeById(nodeId) {
        return this.nodes.find(node => {
            const parts = node.id.split('_');
            return parts[1] == nodeId;
        });
    }
    
    // Create the D3 visualization
    createVisualization() {
        // Create links
        const link = this.svg.append('g')
            .selectAll('line')
            .data(this.links)
            .enter().append('line')
            .attr('stroke', d => this.getLinkColor(d.weight))
            .attr('stroke-width', d => Math.abs(d.weight) * 2 + 1)
            .attr('opacity', 0.6);
        
        // Create nodes
        const node = this.svg.append('g')
            .selectAll('circle')
            .data(this.nodes)
            .enter().append('circle')
            .attr('r', 8)
            .attr('fill', d => this.getNodeColor(d.type))
            .attr('stroke', '#333')
            .attr('stroke-width', 2);
        
        // Add node labels
        const label = this.svg.append('g')
            .selectAll('text')
            .data(this.nodes)
            .enter().append('text')
            .text(d => d.id.split('_')[1])
            .attr('text-anchor', 'middle')
            .attr('dy', '0.35em')
            .attr('font-size', '10px')
            .attr('fill', '#333');
        
        // Create force simulation
        this.simulation = d3.forceSimulation(this.nodes)
            .force('link', d3.forceLink(this.links).id(d => d.id).distance(80))
            .force('charge', d3.forceManyBody().strength(-300))
            .force('center', d3.forceCenter(this.width / 2, this.height / 2))
            .force('x', d3.forceX().x(d => d.x).strength(0.1))
            .force('y', d3.forceY().y(d => d.y).strength(0.1));
        
        // Update positions on tick
        this.simulation.on('tick', () => {
            link
                .attr('x1', d => d.source.x)
                .attr('y1', d => d.source.y)
                .attr('x2', d => d.target.x)
                .attr('y2', d => d.target.y);
            
            node
                .attr('cx', d => d.x)
                .attr('cy', d => d.y);
            
            label
                .attr('x', d => d.x)
                .attr('y', d => d.y);
        });
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
    
    // Get link color based on weight
    getLinkColor(weight) {
        if (weight > 0) {
            return `rgba(76, 175, 80, ${Math.abs(weight)})`; // Green for positive
        } else {
            return `rgba(244, 67, 54, ${Math.abs(weight)})`; // Red for negative
        }
    }
    
    // Update with real-time data
    updateRealTime(network, outputs) {
        if (!network) return;
        
        // Update node activations
        this.nodes.forEach((node, index) => {
            if (outputs && outputs[index] !== undefined) {
                // Scale activation to node size
                const activation = Math.abs(outputs[index]);
                node.activation = activation;
            }
        });
        
        // Update visualization
        this.svg.selectAll('circle')
            .data(this.nodes)
            .transition()
            .duration(100)
            .attr('r', d => 8 + (d.activation || 0) * 5);
    }
    
    // Clear visualization
    clear() {
        this.svg.selectAll('*').remove();
        if (this.simulation) {
            this.simulation.stop();
        }
    }
    
    // Resize visualization
    resize(width, height) {
        this.width = width;
        this.height = height;
        
        this.svg
            .attr('width', width)
            .attr('height', height);
        
        if (this.simulation) {
            this.simulation
                .force('center', d3.forceCenter(width / 2, height / 2));
        }
    }
}

// Evolution statistics visualization
class EvolutionStats {
    constructor(containerId) {
        this.container = d3.select(containerId);
        this.width = 400;
        this.height = 200;
        this.margin = { top: 20, right: 20, bottom: 30, left: 40 };
        
        this.svg = this.container
            .append('svg')
            .attr('width', this.width)
            .attr('height', this.height);
        
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
        
        // Clear previous chart
        this.svg.selectAll('*').remove();
        
        // Create scales
        const xScale = d3.scaleLinear()
            .domain([0, d3.max(this.data, d => d.generation)])
            .range([this.margin.left, this.width - this.margin.right]);
        
        const yScale = d3.scaleLinear()
            .domain([0, d3.max(this.data, d => Math.max(d.best, d.average))])
            .range([this.height - this.margin.bottom, this.margin.top]);
        
        // Create line generators
        const bestLine = d3.line()
            .x(d => xScale(d.generation))
            .y(d => yScale(d.best));
        
        const avgLine = d3.line()
            .x(d => xScale(d.generation))
            .y(d => yScale(d.average));
        
        // Add axes
        const xAxis = d3.axisBottom(xScale);
        const yAxis = d3.axisLeft(yScale);
        
        this.svg.append('g')
            .attr('transform', `translate(0, ${this.height - this.margin.bottom})`)
            .call(xAxis);
        
        this.svg.append('g')
            .attr('transform', `translate(${this.margin.left}, 0)`)
            .call(yAxis);
        
        // Add lines
        this.svg.append('path')
            .datum(this.data)
            .attr('fill', 'none')
            .attr('stroke', '#4CAF50')
            .attr('stroke-width', 2)
            .attr('d', bestLine);
        
        this.svg.append('path')
            .datum(this.data)
            .attr('fill', 'none')
            .attr('stroke', '#2196F3')
            .attr('stroke-width', 2)
            .attr('d', avgLine);
        
        // Add legend
        const legend = this.svg.append('g')
            .attr('transform', `translate(${this.width - 100}, 20)`);
        
        legend.append('line')
            .attr('x1', 0).attr('y1', 0)
            .attr('x2', 20).attr('y2', 0)
            .attr('stroke', '#4CAF50')
            .attr('stroke-width', 2);
        
        legend.append('text')
            .attr('x', 25).attr('y', 5)
            .text('Best')
            .attr('font-size', '12px');
        
        legend.append('line')
            .attr('x1', 0).attr('y1', 20)
            .attr('x2', 20).attr('y2', 20)
            .attr('stroke', '#2196F3')
            .attr('stroke-width', 2);
        
        legend.append('text')
            .attr('x', 25).attr('y', 25)
            .text('Average')
            .attr('font-size', '12px');
    }
    
    // Clear chart
    clear() {
        this.svg.selectAll('*').remove();
        this.data = [];
    }
} 