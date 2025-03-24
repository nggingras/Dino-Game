#ifndef NETWORK_VISUALIZER_H
#define NETWORK_VISUALIZER_H

#include <SDL2/SDL.h>
#include <vector>
#include "Node.h"
#include "Connection.h"

class NetworkVisualizer {
public:
    NetworkVisualizer(int width, int height);
    ~NetworkVisualizer();
    void render(const std::vector<Node*>& inputNodes, const std::vector<Node*>& outputNodes);
    bool isRunning() const;

private:
    SDL_Window* window;
    SDL_Renderer* renderer;
    bool running;
};

#endif
