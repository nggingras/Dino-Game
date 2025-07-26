// Neural Network Visualization using D3.js
const INPUT_LABELS = ['dinoY', 'dinoVelocity', 'obstacleX', 'obstacleHeight'];
const OUTPUT_LABELS = ['jump', 'crouch'];

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
        const defaultRadius = 18;
        const nodeMargin = defaultRadius + 12;
        const leftX = nodeMargin;
        const rightX = this.width - nodeMargin;
        // Input nodes: fixed at left
        for (let i = 0; i < network.numInputs; i++) {
            const y = (this.height - 100) * (i + 1) / (network.numInputs + 1) + 50;
            this.nodes.push({
                id: `input_${i}`,
                type: 'input',
                layer: 0,
                x: leftX,
                y: y,
                fx: leftX,
                fy: y,
                label: INPUT_LABELS[i] || `input${i}`,
                genomeId: i // input node id in genome
            });
        }
        // Hidden nodes: distributed between input and output
        let maxLayer = 1;
        if (network.nodes) {
            maxLayer = Math.max(1, ...network.nodes.map(n => n.layer));
            const hiddenNodes = network.nodes.filter(node => node.type === 'hidden');
            hiddenNodes.forEach((node, index) => {
                const x = leftX + (rightX - leftX) * (node.layer / (maxLayer + 1));
                const y = (this.height - 100) * (index + 1) / (hiddenNodes.length + 1) + 50;
                this.nodes.push({
                    id: `hidden_${node.id}`,
                    type: 'hidden',
                    layer: node.layer,
                    x: x,
                    y: y,
                    genomeId: node.id // hidden node id in genome
                });
            });
        }
        // Output nodes: fixed at right
        for (let i = 0; i < network.numOutputs; i++) {
            const y = (this.height - 100) * (i + 1) / (network.numOutputs + 1) + 50;
            // Output node id in genome is (numInputs + i)
            this.nodes.push({
                id: `output_${i}`,
                type: 'output',
                layer: maxLayer + 1,
                x: rightX,
                y: y,
                fx: rightX,
                fy: y,
                label: OUTPUT_LABELS[i] || `output${i}`,
                genomeId: network.numInputs + i // output node id in genome
            });
        }
        // Build a map from genome node id to D3 node object
        const idToNode = new Map();
        this.nodes.forEach(node => {
            idToNode.set(node.genomeId, node);
        });
        // Add connections using the idToNode map
        if (network.connections) {
            network.connections.forEach(conn => {
                const sourceNode = idToNode.get(conn.fromNode);
                const targetNode = idToNode.get(conn.toNode);
                if (conn.enabled && sourceNode && targetNode) {
                    this.links.push({
                        source: sourceNode,
                        target: targetNode,
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
        const defaultRadius = 18;
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
            .attr('r', defaultRadius)
            .attr('fill', d => this.getNodeColor(d.type))
            .attr('stroke', '#333')
            .attr('stroke-width', 2);
        // Add node labels (only show ID for hidden nodes)
        const label = this.svg.append('g')
            .selectAll('text')
            .data(this.nodes)
            .enter().append('text')
            .text(d => d.type === 'hidden' ? d.genomeId : '')
            .attr('text-anchor', 'middle')
            .attr('dy', '0.35em')
            .attr('font-size', '14px')
            .attr('fill', '#333');
        // Add semantic labels beside input/output nodes
        const semanticLabel = this.svg.append('g')
            .selectAll('text.semantic')
            .data(this.nodes.filter(d => d.type === 'input' || d.type === 'output'))
            .enter().append('text')
            .attr('class', 'semantic')
            .text(d => d.label)
            .attr('x', d => d.type === 'input' ? d.x - 40 : d.x + 40)
            .attr('y', d => d.y + 5)
            .attr('text-anchor', d => d.type === 'input' ? 'end' : 'start')
            .attr('font-size', '13px')
            .attr('fill', '#222');
        // Create force simulation
        this.simulation = d3.forceSimulation(this.nodes)
            .force('link', d3.forceLink(this.links).id(d => d.id).distance(80))
            .force('charge', d3.forceManyBody().strength(-300))
            .force('center', d3.forceCenter(this.width / 2, this.height / 2))
            .force('x', d3.forceX().x(d => d.x).strength(0.1))
            .force('y', d3.forceY().y(d => d.y).strength(0.1));
        // Only hidden nodes are affected by simulation
        this.simulation.nodes().forEach(n => {
            if (n.type === 'input' || n.type === 'output') {
                n.fx = n.x;
                n.fy = n.y;
            }
        });
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
            semanticLabel
                .attr('x', d => d.type === 'input' ? d.x - 40 : d.x + 40)
                .attr('y', d => d.y + 5);
        });
        // After drawing the network, overlay HTML labels for input/output nodes
        // Remove old labels
        d3.select('#networkViz').selectAll('.network-label').remove();
        // Add new labels for input/output nodes
        this.nodes.filter(d => d.type === 'input' || d.type === 'output').forEach(d => {
            let left = d.x;
            let top = d.y;
            // Offset for input/output
            if (d.type === 'input') left += 180;
            if (d.type === 'output') left += 440;
            // Determine value to display
            let value = '';
            if (d.type === 'input' && this.lastInputs) {
                const idx = parseInt(d.id.split('_')[1]);
                value = typeof this.lastInputs[idx] !== 'undefined' ? `: ${this.lastInputs[idx].toFixed(2)}` : '';
            }
            if (d.type === 'output' && this.lastOutputs) {
                const idx = parseInt(d.id.split('_')[1]);
                value = typeof this.lastOutputs[idx] !== 'undefined' ? `: ${this.lastOutputs[idx].toFixed(2)}` : '';
            }
            d3.select('#networkViz')
              .append('div')
              .attr('class', 'network-label')
              .style('left', `${left}px`)
              .style('top', `${top - 10}px`)
              .text(d.label + value);
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
    updateRealTime(inputs, outputs) {
        this.lastInputs = inputs;
        this.lastOutputs = outputs;
        const defaultRadius = 18;
        // Find the input with the largest absolute value
        let maxInputIdx = -1, maxInputVal = -Infinity;
        if (inputs) {
            inputs.forEach((v, i) => {
                if (Math.abs(v) > maxInputVal) {
                    maxInputVal = Math.abs(v);
                    maxInputIdx = i;
                }
            });
        }
        // Highlight input/output nodes
        this.svg.selectAll('circle')
            .attr('r', (d, i) => {
                if (d.type === 'input' && maxInputIdx === parseInt(d.id.split('_')[1])) {
                    return defaultRadius + 6;
                }
                if (d.type === 'output' && outputs) {
                    const idx = parseInt(d.id.split('_')[1]);
                    if (outputs[idx] > 0.5) {
                        return defaultRadius + 6;
                    }
                }
                return defaultRadius;
            })
            .attr('fill', d => {
                if (d.type === 'input' && inputs) {
                    const v = Math.max(0, Math.min(1, Math.abs(inputs[parseInt(d.id.split('_')[1])])));
                    return `rgba(76, 175, 80, ${0.3 + 0.7 * v})`;
                }
                if (d.type === 'output' && outputs) {
                    const idx = parseInt(d.id.split('_')[1]);
                    if (outputs[idx] > 0.5) {
                        return '#FFD700';
                    }
                    return '#FF9800';
                }
                return this.getNodeColor(d.type);
            })
            .attr('stroke-width', d => {
                if (d.type === 'output' && outputs) {
                    const idx = parseInt(d.id.split('_')[1]);
                    if (outputs[idx] > 0.5) {
                        return 5;
                    }
                }
                if (d.type === 'input' && maxInputIdx === parseInt(d.id.split('_')[1])) {
                    return 5;
                }
                return 2;
            });
        // Show hidden node labels only
        this.svg.selectAll('text')
            .filter(d => d && d.type === 'hidden')
            .text(d => d.genomeId);
        // Update semantic labels for input/output nodes to show label and value
        this.svg.selectAll('text.semantic')
            .text(d => {
                if (d.type === 'input' && inputs) {
                    const idx = parseInt(d.id.split('_')[1]);
                    return `${d.label}: ${inputs[idx]?.toFixed(2)}`;
                }
                if (d.type === 'output' && outputs) {
                    const idx = parseInt(d.id.split('_')[1]);
                    return `${d.label}: ${outputs[idx]?.toFixed(2)}`;
                }
                return d.label;
            });
        // --- HTML overlay label update for real-time values ---
        d3.select('#networkViz').selectAll('.network-label').remove();
        this.nodes.filter(d => d.type === 'input' || d.type === 'output').forEach(d => {
            let left = d.x;
            let top = d.y;
            if (d.type === 'input') left += 180;
            if (d.type === 'output') left += 440;
            let value = '';
            if (d.type === 'input' && this.lastInputs) {
                const idx = parseInt(d.id.split('_')[1]);
                value = typeof this.lastInputs[idx] !== 'undefined' ? `: ${this.lastInputs[idx].toFixed(2)}` : '';
            }
            if (d.type === 'output' && this.lastOutputs) {
                const idx = parseInt(d.id.split('_')[1]);
                value = typeof this.lastOutputs[idx] !== 'undefined' ? `: ${this.lastOutputs[idx].toFixed(2)}` : '';
            }
            d3.select('#networkViz')
              .append('div')
              .attr('class', 'network-label')
              .style('left', `${left}px`)
              .style('top', `${top - 10}px`)
              .text(d.label + value);
        });
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