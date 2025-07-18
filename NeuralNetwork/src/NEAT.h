// File: NEAT.h
// Description: Definition of the NEAT (NeuroEvolution of Augmenting Topologies) classes
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-23  

#ifndef NEAT_H
#define NEAT_H

#include <vector>
#include <unordered_map>
#include <memory>
#include <functional>
#include "neuralNetwork.h"

// Forward declarations
class Genome;
class Species;
class Innovation;

// Innovation tracking for NEAT
class Innovation {
public:
    enum Type {
        NEW_CONNECTION,
        NEW_NODE
    };

    Innovation(Type _type, int _fromNode, int _toNode, int _innovationNumber, int _newNodeId = -1);
    
    Type getType() const { return m_type; }
    int getFromNode() const { return m_fromNode; }
    int getToNode() const { return m_toNode; }
    int getInnovationNumber() const { return m_innovationNumber; }
    int getNewNodeId() const { return m_newNodeId; }

private:
    Type m_type;
    int m_fromNode;
    int m_toNode;
    int m_innovationNumber;
    int m_newNodeId; // Only used for NEW_NODE innovations
};

// Genome represents a neural network topology and weights
class Genome {
public:
    struct ConnectionGene {
        int fromNode;
        int toNode;
        double weight;
        bool enabled;
        int innovationNumber;
        
        ConnectionGene(int _from, int _to, double _w, bool _enabled, int _innov)
            : fromNode(_from), toNode(_to), weight(_w), enabled(_enabled), innovationNumber(_innov) {}
    };

    struct NodeGene {
        int nodeId;
        double bias;
        bool isInput;
        bool isOutput;
        
        NodeGene(int _id, double _bias, bool _input, bool _output)
            : nodeId(_id), bias(_bias), isInput(_input), isOutput(_output) {}
    };

    Genome();
    ~Genome();

    // Genome operations
    void addNode(int _nodeId, double _bias, bool _isInput, bool _isOutput);
    void addConnection(int _fromNode, int _toNode, double _weight, int _innovationNumber);
    void mutate();
    void mutateWeights();
    void mutateAddConnection();
    void mutateAddNode();
    void mutateToggleConnection();
    
    // Fitness and compatibility
    double getFitness() const { return m_fitness; }
    void setFitness(double _fitness) { m_fitness = _fitness; }
    double getAdjustedFitness() const { return m_adjustedFitness; }
    void setAdjustedFitness(double _fitness) { m_adjustedFitness = _fitness; }
    
    // Compatibility distance for speciation
    double compatibilityDistance(const Genome& _other) const;
    
    // Convert to neural network
    std::unique_ptr<neuralNetwork> createNeuralNetwork() const;
    
    // Crossover
    static Genome crossover(const Genome& _parent1, const Genome& _parent2);

private:
    std::vector<NodeGene> m_nodes;
    std::vector<ConnectionGene> m_connections;
    double m_fitness;
    double m_adjustedFitness;
};

// Species groups similar genomes together
class Species {
public:
    Species(Genome* _representative);
    ~Species();

    void addGenome(Genome* _genome);
    void removeGenome(Genome* _genome);
    bool isCompatible(const Genome& _genome) const;
    void calculateAdjustedFitness();
    Genome* selectParent() const;
    void cull(bool _keepBest = true);
    void reproduce();
    
    double getTotalAdjustedFitness() const { return m_totalAdjustedFitness; }
    size_t getSize() const { return m_genomes.size(); }
    const std::vector<Genome*>& getGenomes() const { return m_genomes; }

private:
    Genome* m_representative;
    std::vector<Genome*> m_genomes;
    double m_totalAdjustedFitness;
    int m_staleness; // Generations without improvement
};

// Main NEAT algorithm class
class NEAT {
public:
    struct Config {
        int populationSize = 150;
        int numInputs = 4;
        int numOutputs = 1;
        double compatibilityThreshold = 3.0;
        double weightMutationRate = 0.8;
        double weightMutationPower = 0.1;
        double addConnectionRate = 0.05;
        double addNodeRate = 0.03;
        double toggleConnectionRate = 0.1;
        double crossoverRate = 0.75;
        double survivalThreshold = 0.2;
    };

    NEAT(const Config& _config);
    ~NEAT();

    void initializePopulation();
    void evolve();
    void evaluateFitness(std::function<double(const Genome&)> _fitnessFunction);
    Genome* getBestGenome() const;
    
    // Innovation tracking
    int getNextInnovationNumber() { return m_nextInnovationNumber++; }
    int getNextNodeId() { return m_nextNodeId++; }
    
    const Config& getConfig() const { return m_config; }
    std::vector<Genome*>& getPopulation() { return m_population; }

private:
    Config m_config;
    std::vector<Genome*> m_population;
    std::vector<Species*> m_species;
    std::vector<Innovation> m_innovations;
    
    int m_nextInnovationNumber;
    int m_nextNodeId;
    
    void speciate();
    void calculateAdjustedFitness();
    void removeStaleSpecies();
    void removeWeakSpecies();
    void reproduce();
    void addToSpecies(Genome* _genome);
};

#endif // NEAT_H 