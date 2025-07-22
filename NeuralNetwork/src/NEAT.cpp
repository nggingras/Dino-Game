// File: NEAT.cpp
// Description: Implementation of the NEAT (NeuroEvolution of Augmenting Topologies) classes
// Author: Nicolas Gauvin-Gingras  
// Date: 2025-03-23  

#include <algorithm>
#include <random>
#include <functional>
#include <cmath>
#include "NEAT.h"

// Innovation implementation
Innovation::Innovation(Type _type, int _fromNode, int _toNode, int _innovationNumber, int _newNodeId)
    : m_type(_type), 
      m_fromNode(_fromNode), 
      m_toNode(_toNode), 
      m_innovationNumber(_innovationNumber), 
      m_newNodeId(_newNodeId)
{
}

// Genome implementation
Genome::Genome() 
    : m_fitness(0.0), 
      m_adjustedFitness(0.0)
{
}

Genome::~Genome()
{
}

void Genome::addNode(int _nodeId, double _bias, bool _isInput, bool _isOutput)
{
    m_nodes.emplace_back(_nodeId, _bias, _isInput, _isOutput);
}

void Genome::addConnection(int _fromNode, int _toNode, double _weight, int _innovationNumber)
{
    m_connections.emplace_back(_fromNode, _toNode, _weight, true, _innovationNumber);
}

void Genome::mutate()
{
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_real_distribution<> dis(0.0, 1.0);
    
    // Weight mutations
    if (dis(gen) < 0.8) // 80% chance
    {
        mutateWeights();
    }
    
    // Add connection mutation
    if (dis(gen) < 0.05) // 5% chance
    {
        mutateAddConnection();
    }
    
    // Add node mutation
    if (dis(gen) < 0.03) // 3% chance
    {
        mutateAddNode();
    }
    
    // Toggle connection mutation
    if (dis(gen) < 0.1) // 10% chance
    {
        mutateToggleConnection();
    }
}

void Genome::mutateWeights()
{
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_real_distribution<> dis(-0.1, 0.1);
    
    for (auto& connection : m_connections)
    {
        connection.weight += dis(gen);
    }
    
    for (auto& node : m_nodes)
    {
        if (!node.isInput)
        {
            node.bias += dis(gen);
        }
    }
}

void Genome::mutateAddConnection()
{
    // This would need to be implemented with innovation tracking
    // For now, we'll skip this mutation
}

void Genome::mutateAddNode()
{
    // This would need to be implemented with innovation tracking
    // For now, we'll skip this mutation
}

void Genome::mutateToggleConnection()
{
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<> dis(0, m_connections.size() - 1);
    
    if (!m_connections.empty())
    {
        int index = dis(gen);
        m_connections[index].enabled = !m_connections[index].enabled;
    }
}

double Genome::compatibilityDistance(const Genome& _other) const
{
    const double c1 = 1.0; // Weight for excess genes
    const double c2 = 1.0; // Weight for disjoint genes
    const double c3 = 0.4; // Weight for weight differences
    
    int excess = 0;
    int disjoint = 0;
    double weightDiff = 0.0;
    int matching = 0;
    
    // Count excess and disjoint genes
    size_t maxInnovation = std::max(
        m_connections.empty() ? 0 : m_connections.back().innovationNumber,
        _other.m_connections.empty() ? 0 : _other.m_connections.back().innovationNumber
    );
    
    for (size_t i = 0; i <= maxInnovation; ++i)
    {
        auto it1 = std::find_if(m_connections.begin(), m_connections.end(),
            [i](const ConnectionGene& c) { return c.innovationNumber == i; });
        auto it2 = std::find_if(_other.m_connections.begin(), _other.m_connections.end(),
            [i](const ConnectionGene& c) { return c.innovationNumber == i; });
        
        if (it1 != m_connections.end() && it2 != _other.m_connections.end())
        {
            // Matching gene
            matching++;
            weightDiff += std::abs(it1->weight - it2->weight);
        }
        else if (it1 != m_connections.end() || it2 != _other.m_connections.end())
        {
            // Disjoint or excess gene
            if (i > std::min(
                m_connections.empty() ? 0 : m_connections.back().innovationNumber,
                _other.m_connections.empty() ? 0 : _other.m_connections.back().innovationNumber
            ))
            {
                excess++;
            }
            else
            {
                disjoint++;
            }
        }
    }
    
    int N = std::max(m_connections.size(), _other.m_connections.size());
    if (N < 20) N = 1; // Normalize by genome size
    
    return (c1 * excess + c2 * disjoint) / N + c3 * (matching > 0 ? weightDiff / matching : 0);
}

std::unique_ptr<neuralNetwork> Genome::createNeuralNetwork() const
{
    // Count input and output nodes
    int numInputs = 0, numOutputs = 0, numHidden = 0;
    for (const auto& node : m_nodes)
    {
        if (node.isInput) numInputs++;
        else if (node.isOutput) numOutputs++;
        else numHidden++;
    }
    
    // Create neural network
    auto network = std::make_unique<neuralNetwork>(numInputs, numHidden, numOutputs);
    
    // Create a mapping from genome node IDs to neural network nodes
    std::unordered_map<int, Node*> nodeMap;
    
    // Map input nodes
    int inputIndex = 0;
    for (const auto& nodeGene : m_nodes)
    {
        if (nodeGene.isInput)
        {
            if (inputIndex < network->m_vInputNodes.size())
            {
                nodeMap[nodeGene.nodeId] = network->m_vInputNodes[inputIndex];
                inputIndex++;
            }
        }
    }
    
    // Map hidden nodes
    int hiddenIndex = 0;
    for (const auto& nodeGene : m_nodes)
    {
        if (!nodeGene.isInput && !nodeGene.isOutput)
        {
            if (hiddenIndex < network->m_vHiddenNodes.size())
            {
                nodeMap[nodeGene.nodeId] = network->m_vHiddenNodes[hiddenIndex];
                hiddenIndex++;
            }
        }
    }
    
    // Map output nodes
    int outputIndex = 0;
    for (const auto& nodeGene : m_nodes)
    {
        if (nodeGene.isOutput)
        {
            if (outputIndex < network->m_vOutputNodes.size())
            {
                nodeMap[nodeGene.nodeId] = network->m_vOutputNodes[outputIndex];
                outputIndex++;
            }
        }
    }
    
    // Add connections
    for (const auto& connection : m_connections)
    {
        if (connection.enabled)
        {
            auto fromIt = nodeMap.find(connection.fromNode);
            auto toIt = nodeMap.find(connection.toNode);
            
            if (fromIt != nodeMap.end() && toIt != nodeMap.end())
            {
                Connection* conn = new Connection(fromIt->second, toIt->second, connection.weight, true);
                toIt->second->addInputConnection(conn);
            }
        }
    }
    
    return network;
}

Genome Genome::crossover(const Genome& _parent1, const Genome& _parent2)
{
    Genome child;
    
    // Copy nodes from the more fit parent
    if (_parent1.m_fitness > _parent2.m_fitness)
    {
        child.m_nodes = _parent1.m_nodes;
    }
    else
    {
        child.m_nodes = _parent2.m_nodes;
    }
    
    // Crossover connections
    size_t maxInnovation = std::max(
        _parent1.m_connections.empty() ? 0 : _parent1.m_connections.back().innovationNumber,
        _parent2.m_connections.empty() ? 0 : _parent2.m_connections.back().innovationNumber
    );
    
    for (size_t i = 0; i <= maxInnovation; ++i)
    {
        auto it1 = std::find_if(_parent1.m_connections.begin(), _parent1.m_connections.end(),
            [i](const ConnectionGene& c) { return c.innovationNumber == i; });
        auto it2 = std::find_if(_parent2.m_connections.begin(), _parent2.m_connections.end(),
            [i](const ConnectionGene& c) { return c.innovationNumber == i; });
        
        if (it1 != _parent1.m_connections.end() && it2 != _parent2.m_connections.end())
        {
            // Both parents have this gene - randomly choose one
            static std::random_device rd;
            static std::mt19937 gen(rd());
            static std::uniform_int_distribution<> dis(0, 1);
            
            const ConnectionGene& chosen = (dis(gen) == 0) ? *it1 : *it2;
            child.m_connections.push_back(chosen);
        }
        else if (it1 != _parent1.m_connections.end())
        {
            // Only parent1 has this gene
            child.m_connections.push_back(*it1);
        }
        else if (it2 != _parent2.m_connections.end())
        {
            // Only parent2 has this gene
            child.m_connections.push_back(*it2);
        }
    }
    
    return child;
}

// Species implementation
Species::Species(Genome* _representative) 
    : m_representative(_representative), m_totalAdjustedFitness(0.0), m_staleness(0)
{
    addGenome(_representative);
}

Species::~Species()
{
}

void Species::addGenome(Genome* _genome)
{
    m_genomes.push_back(_genome);
}

void Species::removeGenome(Genome* _genome)
{
    auto it = std::find(m_genomes.begin(), m_genomes.end(), _genome);
    if (it != m_genomes.end())
    {
        m_genomes.erase(it);
    }
}

bool Species::isCompatible(const Genome& _genome) const
{
    return m_representative->compatibilityDistance(_genome) < 3.0; // Compatibility threshold
}

void Species::calculateAdjustedFitness()
{
    m_totalAdjustedFitness = 0.0;
    for (auto genome : m_genomes)
    {
        m_totalAdjustedFitness += genome->getAdjustedFitness();
    }
}

Genome* Species::selectParent() const
{
    if (m_genomes.empty()) return nullptr;
    
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_real_distribution<> dis(0.0, 1.0);
    
    double random = dis(gen) * m_totalAdjustedFitness;
    double sum = 0.0;
    
    for (auto genome : m_genomes)
    {
        sum += genome->getAdjustedFitness();
        if (sum >= random)
        {
            return genome;
        }
    }
    
    return m_genomes.back();
}

void Species::cull(bool _keepBest)
{
    if (m_genomes.size() <= 2) return;
    
    // Sort by fitness
    std::sort(m_genomes.begin(), m_genomes.end(),
        [](const Genome* a, const Genome* b) { return a->getFitness() > b->getFitness(); });
    
    // Keep only the best 20%
    size_t keepCount = std::max(size_t(1), m_genomes.size() / 5);
    if (_keepBest) keepCount = std::max(size_t(1), keepCount);
    
    m_genomes.resize(keepCount);
}

void Species::reproduce()
{
    // This would create new genomes for the species
    // Implementation depends on the NEAT algorithm's reproduction strategy
}

// NEAT implementation
NEAT::NEAT(const Config& _config) 
    : m_config(_config), m_nextInnovationNumber(0), m_nextNodeId(0)
{
}

NEAT::~NEAT()
{
    for (auto genome : m_population)
    {
        delete genome;
    }
    for (auto species : m_species)
    {
        delete species;
    }
}

void NEAT::initializePopulation()
{
    // Create initial minimal genomes
    for (int i = 0; i < m_config.populationSize; ++i)
    {
        Genome* genome = new Genome();
        
        // Add input nodes
        for (int j = 0; j < m_config.numInputs; ++j)
        {
            genome->addNode(j, 0.0, true, false);
        }
        
        // Add output nodes
        for (int j = 0; j < m_config.numOutputs; ++j)
        {
            genome->addNode(m_config.numInputs + j, 0.0, false, true);
        }
        
        // Add random connections from inputs to outputs
        static std::random_device rd;
        static std::mt19937 gen(rd());
        static std::uniform_real_distribution<> weightDis(-1.0, 1.0);
        static std::uniform_real_distribution<> connectionDis(0.0, 1.0);
        
        for (int input = 0; input < m_config.numInputs; ++input)
        {
            for (int output = 0; output < m_config.numOutputs; ++output)
            {
                // 70% chance to create a connection
                if (connectionDis(gen) < 0.7)
                {
                    double weight = weightDis(gen);
                    int innovation = getNextInnovationNumber();
                    genome->addConnection(input, m_config.numInputs + output, weight, innovation);
                }
            }
        }
        
        m_population.push_back(genome);
    }
}

void NEAT::evolve()
{
    speciate();
    calculateAdjustedFitness();
    removeStaleSpecies();
    removeWeakSpecies();
    reproduce();
}

void NEAT::evaluateFitness(std::function<double(const Genome&)> _fitnessFunction)
{
    for (auto genome : m_population)
    {
        double fitness = _fitnessFunction(*genome);
        genome->setFitness(fitness);
    }
}

Genome* NEAT::getBestGenome() const
{
    if (m_population.empty()) return nullptr;
    
    return *std::max_element(m_population.begin(), m_population.end(),
        [](const Genome* a, const Genome* b) { return a->getFitness() < b->getFitness(); });
}

void NEAT::speciate()
{
    // Clear existing species
    for (auto species : m_species)
    {
        delete species;
    }
    m_species.clear();
    
    // Assign genomes to species
    for (auto genome : m_population)
    {
        addToSpecies(genome);
    }
}

void NEAT::calculateAdjustedFitness()
{
    for (auto species : m_species)
    {
        species->calculateAdjustedFitness();
    }
}

void NEAT::removeStaleSpecies()
{
    // Remove species that haven't improved for many generations
    m_species.erase(
        std::remove_if(m_species.begin(), m_species.end(),
            [](Species* species) { return species->getSize() == 0; }),
        m_species.end()
    );
}

void NEAT::removeWeakSpecies()
{
    double totalFitness = 0.0;
    for (auto species : m_species)
    {
        totalFitness += species->getTotalAdjustedFitness();
    }
    
    m_species.erase(
        std::remove_if(m_species.begin(), m_species.end(),
            [totalFitness](Species* species) {
                return species->getTotalAdjustedFitness() / totalFitness < 0.001;
            }),
        m_species.end()
    );
}

void NEAT::reproduce()
{
    // This would implement the reproduction strategy
    // Creating new genomes for the next generation
}

void NEAT::addToSpecies(Genome* _genome)
{
    for (auto species : m_species)
    {
        if (species->isCompatible(*_genome))
        {
            species->addGenome(_genome);
            return;
        }
    }
    
    // Create new species if no compatible species found
    m_species.push_back(new Species(_genome));
} 