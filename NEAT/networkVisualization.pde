// Network visualization class for NEAT neural networks
class NetworkVisualization {
  
  // Visualization properties
  float vizX, vizY, vizWidth, vizHeight;
  boolean isVisible = true;
  
  // Colors
  color inputColor = color(100, 200, 100);    // Green for inputs
  color hiddenColor = color(100, 150, 255);   // Blue for hidden
  color outputColor = color(255, 150, 100);   // Orange for outputs
  color highlightColor = color(255, 255, 100); // Yellow for active outputs
  color bgColor = color(248, 249, 250, 240);  // Semi-transparent background
  
  // Node properties
  float nodeRadius = 12;  // Slightly smaller nodes
  float layerSpacing = 80;
  float nodeSpacing = 50; // Reduced spacing for 8 inputs
  
  NetworkVisualization() {
    // Set dimensions for the visualization
    // Adjusted dimensions to fit better on screen while showing 8 inputs
    vizWidth = 380;  // Slightly reduced width
    vizHeight = 260; // Reduced height for better fit
  }

  
  // Draw the neural network visualization for the best dino
  void draw(Population pop) {
    if (!isVisible || pop.aliveCount == 0) return;
    
    // Find the best performing dino
    Dino bestDino = getBestDino(pop);
    if (bestDino == null || bestDino.brain == null) return;
    
    // Calculate position fresh each time to ensure stability
    // Center horizontally with safety margins
    vizX = max(20, (width - vizWidth) / 2);
    vizX = min(vizX, width - vizWidth - 20);
    
    // Position in middle-top area, well below any UI text
    vizY = 120; // Increased margin to avoid overlap with stats text
    vizY = min(vizY, height - vizHeight - 50); // Ensure it fits on screen
    
    // Draw background
    //drawBackground(); //NGG Bug here, commented out to avoid issues
    
    // Draw network
    drawNetwork(bestDino.brain, bestDino, pop.obstacleManager);
    
    // Draw generation info
    drawGenerationInfo(pop);
  }
  
  // Get the best performing dino from the population
  Dino getBestDino(Population pop) {
    Dino best = null;
    float bestScore = -1;
    
    for (Dino dino : pop.dinos) {
      if (!dino.isDead() && dino.score > bestScore) {
        bestScore = dino.score;
        best = dino;
      }
    }
    
    return best;
  }
  
  // Draw semi-transparent background
  void drawBackground() {
    fill(bgColor);
    stroke(60);
    strokeWeight(2);
    rect(vizX, vizY, vizWidth, vizHeight, 8);
  }
  
  // Draw the neural network
  void drawNetwork(Genotype brain, Dino bestDino, ObstacleManager obstacleManager) {
    if (brain == null) return;
    
    // Get current network inputs and outputs
    float[] inputs = bestDino.getSensorInputs(obstacleManager);
    float[] outputs = brain.feedForward(inputs);
    
    // Organize nodes by type
    ArrayList<NodeGene> inputNodes = new ArrayList<NodeGene>();
    ArrayList<NodeGene> hiddenNodes = new ArrayList<NodeGene>();
    ArrayList<NodeGene> outputNodes = new ArrayList<NodeGene>();
    
    for (NodeGene node : brain.nodes) {
      if (node.m_type == NodeGene.INPUT) inputNodes.add(node);
      else if (node.m_type == NodeGene.HIDDEN) hiddenNodes.add(node);
      else if (node.m_type == NodeGene.OUTPUT) outputNodes.add(node);
    }
    
    // Calculate positions once (still needed for connections)
    HashMap<Integer, PVector> nodePositions = calculateNodePositions(inputNodes, hiddenNodes, outputNodes);
    
    // Draw connections first
    drawConnections(brain, nodePositions);
    
    // Draw nodes and labels in one pass
    drawNodesAndLabels(inputNodes, hiddenNodes, outputNodes, nodePositions, inputs, outputs);
  }
  
  // Combined function to draw nodes and labels together
  void drawNodesAndLabels(ArrayList<NodeGene> inputNodes, ArrayList<NodeGene> hiddenNodes, 
                       ArrayList<NodeGene> outputNodes, HashMap<Integer, PVector> nodePositions,
                       float[] inputs, float[] outputs) {
    strokeWeight(2);
    String[] inputLabels = {"obstDist", "obstH", "isCactus", "isBird", "birdH", "secDist", "secBird", "dinoY"};
    String[] outputLabels = {"jump", "crouch"};
    
    // Draw input nodes with labels in one pass
    for (int i = 0; i < inputNodes.size(); i++) {
      PVector pos = nodePositions.get(inputNodes.get(i).m_id);
      if (pos != null) {
        // Draw node
        fill(inputColor);
        stroke(60);
        ellipse(pos.x, pos.y, nodeRadius * 2, nodeRadius * 2);
        
        // Draw labels immediately
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(20);
        if (i < inputLabels.length) {
          text(inputLabels[i], pos.x - 50, pos.y - nodeRadius + 10);
        }
        if (i < inputs.length) {
          text(nf(inputs[i], 1, 2), pos.x, pos.y + nodeRadius + 8);
        }
      }
    }
    
    // Draw hidden nodes
    for (NodeGene node : hiddenNodes) {
      PVector pos = nodePositions.get(node.m_id);
      if (pos != null) {
        fill(hiddenColor);
        stroke(60);
        ellipse(pos.x, pos.y, nodeRadius * 2, nodeRadius * 2);
      }
    }
    
    // Draw output nodes with labels in one pass
    for (int i = 0; i < outputNodes.size(); i++) {
      PVector pos = nodePositions.get(outputNodes.get(i).m_id);
      if (pos != null) {
        // Draw node with activation highlighting
        if (i < outputs.length && outputs[i] > 0.5) {
          fill(highlightColor);
        } else {
          fill(outputColor);
        }
        stroke(60);
        ellipse(pos.x, pos.y, nodeRadius * 2, nodeRadius * 2);
        
        // Draw labels immediately
        fill(0);
        textAlign(CENTER, CENTER);
        textSize(20);
        if (i < outputLabels.length) {
          text(outputLabels[i], pos.x + 45, pos.y - nodeRadius + 10);
        }
        if (i < outputs.length) {
          text(nf(outputs[i], 1, 2), pos.x, pos.y + nodeRadius + 8);
        }
      }
    }
  }
  
  // Calculate positions for all nodes
  HashMap<Integer, PVector> calculateNodePositions(ArrayList<NodeGene> inputNodes, 
                                                  ArrayList<NodeGene> hiddenNodes, 
                                                  ArrayList<NodeGene> outputNodes) {
    HashMap<Integer, PVector> positions = new HashMap<Integer, PVector>();
    
    // Input nodes on the left
    float inputX = vizX + 40;
    float inputStartY = vizY + (vizHeight - (inputNodes.size() * nodeSpacing)) / 2;
    for (int i = 0; i < inputNodes.size(); i++) {
      positions.put(inputNodes.get(i).m_id, new PVector(inputX, inputStartY + i * nodeSpacing));
    }
    
    // Hidden nodes in the middle
    if (hiddenNodes.size() > 0) {
      float hiddenX = vizX + vizWidth / 2;
      float hiddenStartY = vizY + (vizHeight - (hiddenNodes.size() * nodeSpacing)) / 2;
      for (int i = 0; i < hiddenNodes.size(); i++) {
        positions.put(hiddenNodes.get(i).m_id, new PVector(hiddenX, hiddenStartY + i * nodeSpacing));
      }
    }
    
    // Output nodes on the right
    float outputX = vizX + vizWidth - 40;
    float outputStartY = vizY + (vizHeight - (outputNodes.size() * nodeSpacing)) / 2;
    for (int i = 0; i < outputNodes.size(); i++) {
      positions.put(outputNodes.get(i).m_id, new PVector(outputX, outputStartY + i * nodeSpacing));
    }
    
    return positions;
  }
  
  // Draw connections between nodes
  void drawConnections(Genotype brain, HashMap<Integer, PVector> nodePositions) {
    for (ConnectionGene conn : brain.connections) {
      if (!conn.m_enabled) continue;
      
      PVector fromPos = nodePositions.get(conn.m_inNode.m_id);
      PVector toPos = nodePositions.get(conn.m_outNode.m_id);
      
      if (fromPos != null && toPos != null) {
        // Color based on weight (green for positive, red for negative)
        if (conn.m_weight > 0) {
          stroke(100, 200, 100, 150);
        } else {
          stroke(200, 100, 100, 150);
        }
        
        // Line thickness based on weight magnitude
        strokeWeight(map(abs((float)conn.m_weight), 0, 2, 1, 3));
        
        line(fromPos.x, fromPos.y, toPos.x, toPos.y);
      }
    }
  }

  // Draw labels for nodes showing their values
  void drawNodeLabels(HashMap<Integer, PVector> nodePositions, float[] inputs, float[] outputs) {
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(20); // Slightly smaller to fit more labels
    
    // Input labels with values
    String[] inputLabels = {"obstDist", "obstH", "isCactus", "isBird", "birdH", "secDist", "secBird", "dinoY"};
    for (int i = 0; i < min(inputs.length, inputLabels.length); i++) {
      PVector pos = nodePositions.get(i);
      if (pos != null) {
        text(inputLabels[i], pos.x - 50, pos.y - nodeRadius + 10);
        text(nf(inputs[i], 1, 2), pos.x, pos.y + nodeRadius + 8);
      }
    }
    
    // Output labels with values
    String[] outputLabels = {"jump", "crouch"};
    for (int i = 0; i < min(outputs.length, outputLabels.length); i++) {
      // Output nodes start after input nodes in the node list
      PVector pos = nodePositions.get(inputs.length + i);
      if (pos != null) {
        text(outputLabels[i], pos.x + 45, pos.y - nodeRadius + 10);
        text(nf(outputs[i], 1, 2), pos.x, pos.y + nodeRadius + 8);
      }
    }
  }
  
  // Draw generation and network info
  void drawGenerationInfo(Population pop) {
    fill(0);
    textAlign(RIGHT, CENTER);
    textSize(20);
    text("Generation: " + pop.generation, vizX + vizWidth - 125, vizY + vizHeight + 65);
    
    textAlign(RIGHT, CENTER);
    text("Network Topology", vizX + vizWidth - 95, vizY - 95);
  }
  
  // Toggle visibility
  void toggleVisibility() {
    isVisible = !isVisible;
  }
  
  // Set visibility
  void setVisible(boolean visible) {
    isVisible = visible;
  }
}