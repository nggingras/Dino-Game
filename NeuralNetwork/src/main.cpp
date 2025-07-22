// File: main.cpp
// Description: NEAT WebSocket Server for Dino Game AI Training (using SimpleWebSocketServer)
// Author: Nicolas Gauvin-Gingras
// Date: 2025

#define _CRT_SECURE_NO_WARNINGS

#include <iostream>
#include <vector>
#include <map>
#include <queue>
#include <mutex>
#include <thread>
#include <chrono>
#include <memory>
#include <string>
#include <sstream>
#include <iomanip>
#include <nlohmann/json.hpp>
#include "websocket.h"
#include "NEAT.h"

using std::cout;
using std::cerr;
using std::endl;
using std::string;
using std::stringstream;
using json = nlohmann::json;

// WebSocket server
std::unique_ptr<SimpleWebSocketServer> server;
std::mutex clientMutex;
bool clientConnected = false;

// NEAT state
NEAT* neat = nullptr;
std::queue<int> genomeQueue;
std::map<int, double> fitnessResults;
std::mutex neatMutex;
bool trainingActive = false;
int currentGeneration = 1;
int genomesTested = 0;
int totalGenomes = 0;

// Convert NEAT genome to JSON for web client
json genomeToJSON(Genome* genome) {
    json genomeData;
    genomeData["id"] = static_cast<int>(reinterpret_cast<uintptr_t>(genome));
    genomeData["numInputs"] = neat->getConfig().numInputs;
    genomeData["numOutputs"] = neat->getConfig().numOutputs;

    // Nodes
    json nodes = json::array();
    for (const auto& node : genome->m_nodes) {
        std::string type;
        if (node.isInput) type = "input";
        else if (node.isOutput) type = "output";
        else type = "hidden";
        // For visualization, try to infer layer: input=0, output=last, hidden=1 (or more if needed)
        int layer = node.isInput ? 0 : (node.isOutput ? 2 : 1);
        nodes.push_back({
            {"id", node.nodeId},
            {"layer", layer},
            {"type", type},
            {"bias", node.bias}
        });
    }
    genomeData["nodes"] = nodes;

    // Connections
    json connections = json::array();
    for (const auto& conn : genome->m_connections) {
        connections.push_back({
            {"fromNode", conn.fromNode},
            {"toNode", conn.toNode},
            {"weight", conn.weight},
            {"enabled", conn.enabled},
            {"innovationNumber", conn.innovationNumber}
        });
    }
    genomeData["connections"] = connections;
    return genomeData;
}

// Send a genome to the web client for testing
void sendNextGenome() {
    int genomeId = -1;
    Genome* genome = nullptr;
    
    // Get genome data without holding both locks simultaneously
    {
        std::lock_guard<std::mutex> lock(neatMutex);
        if (genomeQueue.empty()) return;
        
        genomeId = genomeQueue.front();
        genomeQueue.pop();
        
        // Find the genome in the population
        auto& population = neat->getPopulation();
        for (auto* g : population) {
            if (static_cast<int>(reinterpret_cast<uintptr_t>(g)) == genomeId) {
                genome = g;
                break;
            }
        }
    }
    
    // Check client connection separately
    {
        std::lock_guard<std::mutex> clientLock(clientMutex);
        if (!clientConnected || !genome) return;
        
        json message;
        message["type"] = "genome";
        message["genome"] = genomeToJSON(genome);
        
        if (server) {
            server->sendMessage(message.dump());
            cout << "Sent genome " << genomeId << " for testing" << endl;
        }
    }
}

// Start NEAT training
void startTraining() {
    {
        std::lock_guard<std::mutex> lock(neatMutex);
        if (!neat) {
            NEAT::Config config;
            config.populationSize = 30;
            config.numInputs = 4; // dinoY, dinoVelocity, obstacleX, obstacleHeight
            config.numOutputs = 2; // jump, crouch
            config.compatibilityThreshold = 30;
            config.weightMutationRate = 0.01;
            config.addNodeRate = 0.3;
            config.addConnectionRate = 0.5;
            neat = new NEAT(config);
            neat->initializePopulation();
            cout << "NEAT initialized with population size: " << config.populationSize << endl;
        }
        
        auto& population = neat->getPopulation();
        genomeQueue = std::queue<int>();
        fitnessResults.clear();
        genomesTested = 0;
        totalGenomes = static_cast<int>(population.size());
        
        for (auto* genome : population) {
            genomeQueue.push(static_cast<int>(reinterpret_cast<uintptr_t>(genome)));
        }
        
        trainingActive = true;
    }
    
    cout << "Starting generation " << currentGeneration << " with " << totalGenomes << " genomes" << endl;
    sendNextGenome();
}

// Evolve to next generation
void evolveGeneration() {
    cout << "Generation " << currentGeneration << " complete!" << endl;
    
    double bestFitness = 0.0;
    double avgFitness = 0.0;
    
    {
        std::lock_guard<std::mutex> lock(neatMutex);
        auto& population = neat->getPopulation();
        
        for (auto* genome : population) {
            auto it = fitnessResults.find(static_cast<int>(reinterpret_cast<uintptr_t>(genome)));
            if (it != fitnessResults.end()) {
                genome->setFitness(it->second);
            } else {
                genome->setFitness(0.0);
            }
        }
        
        for (auto* genome : population) {
            bestFitness = max(bestFitness, genome->getFitness());
            avgFitness += genome->getFitness();
        }
        avgFitness /= population.size();
        
        neat->evolve();
        currentGeneration++;
    }
    
    cout << "Best fitness: " << bestFitness << endl;
    cout << "Average fitness: " << avgFitness << endl;
    
    json stats;
    stats["type"] = "evolution_stats";
    stats["generation"] = currentGeneration;
    stats["bestFitness"] = bestFitness;
    stats["avgFitness"] = avgFitness;
    
    // Send stats without holding the neatMutex
    json statsCopy = stats;
    std::lock_guard<std::mutex> clientLock(clientMutex);
    if (server) {
        server->sendMessage(statsCopy.dump());
    }
    
    cout << "Evolved to generation " << currentGeneration << endl;
}

// Handle WebSocket messages
void handleMessage(const string& message) {
    try {
        json data = json::parse(message);
        string type = data["type"];
        
        if (type == "fitness") {
            int genomeId = data["genomeId"];
            double fitness = data["fitness"];
            
            bool shouldEvolve = false;
            bool shouldSendNext = false;
            
            {
                std::lock_guard<std::mutex> lock(neatMutex);
                fitnessResults[genomeId] = fitness;
                genomesTested++;
                
                cout << "Genome " << genomeId << " fitness: " << fitness << " (" << genomesTested << "/" << totalGenomes << ")" << endl;
                
                if (genomesTested >= totalGenomes) {
                    shouldEvolve = true;
                } else {
                    shouldSendNext = true;
                }
            }
            
            if (shouldEvolve) {
                evolveGeneration();
                
                {
                    std::lock_guard<std::mutex> lock(neatMutex);
                    auto& population = neat->getPopulation();
                    genomeQueue = std::queue<int>();
                    fitnessResults.clear();
                    genomesTested = 0;
                    totalGenomes = static_cast<int>(population.size());
                    
                    for (auto* genome : population) {
                        genomeQueue.push(static_cast<int>(reinterpret_cast<uintptr_t>(genome)));
                    }
                }
                
                cout << "Starting generation " << currentGeneration << " with " << totalGenomes << " genomes" << endl;
                sendNextGenome();
            } else if (shouldSendNext) {
                sendNextGenome();
            }
        } else if (type == "ready") {
            cout << "Web client ready for training!" << endl;
            startTraining();
        } else if (type == "ping") {
            json response = { {"type", "pong"} };
            std::lock_guard<std::mutex> clientLock(clientMutex);
            if (server) {
                server->sendMessage(response.dump());
            }
        }
    } catch (const std::exception& e) {
        cerr << "Error processing message: " << e.what() << endl;
    }
}

int main() {
    cout << "=== NEAT WebSocket Server for Dino Game (using SimpleWebSocketServer) ===" << endl;
    cout << "Starting WebSocket server on port 20000..." << endl;
    
    // Create WebSocket server
    server = std::make_unique<SimpleWebSocketServer>();
    
    // Set up callbacks
    server->setMessageCallback(handleMessage);
    server->setConnectCallback([]() {
        cout << "=== CLIENT CONNECTION STARTED ===" << endl;
        std::lock_guard<std::mutex> lock(clientMutex);
        clientConnected = true;
        cout << "WebSocket client connected!" << endl;
    });
    server->setDisconnectCallback([]() {
        cout << "WebSocket client disconnected!" << endl;
        std::lock_guard<std::mutex> lock(clientMutex);
        clientConnected = false;
    });
    
    // Start the server
    if (!server->start(20000)) {
        cerr << "Failed to start WebSocket server" << endl;
        return 1;
    }
    
    cout << "Server listening on port 20000" << endl;
    cout << "Open your web Dino game in the browser to connect." << endl;
    
    // Keep the main thread alive
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    return 0;
}
