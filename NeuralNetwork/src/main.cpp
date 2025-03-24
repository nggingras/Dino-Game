// NeuralNetwork.cpp : Ce fichier contient la fonction 'main'.
//

#include <iostream>


#include "Node.h"
#include "Connection.h"

#include "NetworkVisualizer.h"

int WinMain() {

    NetworkVisualizer visualizer(1000, 1000);

    // Create nodes
    Node input1(0);
    Node input2(1);
    Node output1(0);
    Node output2(1);

    // Create connections
    Connection c1(&input1, &output1, 0.8);
    Connection c2(&input2, &output1, -0.5);
    Connection c3(&input1, &output2, 0.3);
    Connection c4(&input2, &output2, 0.7);

    // Connect nodes addInputConnection
    output1.addInputConnection(&c1);
    output1.addInputConnection(&c2);
    output2.addInputConnection(&c3);
    output2.addInputConnection(&c4);

    // Store nodes
    std::vector<Node*> inputNodes = { &input1, &input2 };
    std::vector<Node*> outputNodes = { &output1, &output2 };

    while (visualizer.isRunning()) {
        visualizer.render(inputNodes, outputNodes);
        SDL_Delay(100);
    }

    return 0;

}
