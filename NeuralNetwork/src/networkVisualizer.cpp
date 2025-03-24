#include "NetworkVisualizer.h"
#include <iostream>
#include <cmath>

const int NODE_RADIUS = 20;
const int INPUT_X = 200;   // X position of input nodes
const int OUTPUT_X = 600;  // X position of output nodes
const int SCREEN_WIDTH = 800;
const int SCREEN_HEIGHT = 600;

NetworkVisualizer::NetworkVisualizer(int width, int height) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL could not initialize! SDL_Error: " << SDL_GetError() << std::endl;
        running = false;
        return;
    }

    window = SDL_CreateWindow("Neural Network Visualizer", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, SDL_WINDOW_SHOWN);
    if (!window) {
        std::cerr << "Window could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        running = false;
        return;
    }

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if (!renderer) {
        std::cerr << "Renderer could not be created! SDL_Error: " << SDL_GetError() << std::endl;
        running = false;
        return;
    }

    running = true;
}

NetworkVisualizer::~NetworkVisualizer() {
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

void NetworkVisualizer::render(const std::vector<Node*>& inputNodes, const std::vector<Node*>& outputNodes) {
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);

    int inputSpacing = SCREEN_HEIGHT / (inputNodes.size() + 1);
    int outputSpacing = SCREEN_HEIGHT / (outputNodes.size() + 1);

    std::vector<std::pair<int, int>> inputPositions;
    std::vector<std::pair<int, int>> outputPositions;

    // Draw input nodes
    for (size_t i = 0; i < inputNodes.size(); ++i) {
        int x = INPUT_X;
        int y = (i + 1) * inputSpacing;
        inputPositions.push_back({ x, y });

        SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
        SDL_Rect rect = { x - NODE_RADIUS, y - NODE_RADIUS, NODE_RADIUS * 2, NODE_RADIUS * 2 };
        SDL_RenderFillRect(renderer, &rect);
    }

    // Draw output nodes
    for (size_t i = 0; i < outputNodes.size(); ++i) {
        int x = OUTPUT_X;
        int y = (i + 1) * outputSpacing;
        outputPositions.push_back({ x, y });

        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        SDL_Rect rect = { x - NODE_RADIUS, y - NODE_RADIUS, NODE_RADIUS * 2, NODE_RADIUS * 2 };
        SDL_RenderFillRect(renderer, &rect);
    }

    // Draw connections
    SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    for (const auto& outputNode : outputNodes) {
        for (const auto& conn : outputNode->getInputConnections()) {
            if (conn->isEnabled()) {
                int fromIndex = conn->getFromNode()->getNodeId();
                int toIndex = conn->getToNode()->getNodeId();

                int x1 = inputPositions[fromIndex].first;
                int y1 = inputPositions[fromIndex].second;
                int x2 = outputPositions[toIndex].first;
                int y2 = outputPositions[toIndex].second;

                SDL_RenderDrawLine(renderer, x1, y1, x2, y2);
            }
        }
    }

    SDL_RenderPresent(renderer);
}

bool NetworkVisualizer::isRunning() const {
    return running;
}
