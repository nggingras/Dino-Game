// Define a class to represent the connection gene of a genotype.
class ConnectionGene {

    NodeGene m_inNode;
    NodeGene m_outNode;
    int m_innovation = 0; // Innovation number is the unique identifier of the connection gene.
    float m_weight = 0.0;
    boolean m_enabled = true;

    ConnectionGene(NodeGene _inNode, NodeGene _outNode, int _innovation, float _weight) {
        m_inNode = _inNode;
        m_outNode = _outNode;
        m_innovation = _innovation;
        m_weight = _weight;
    }

    // Copy constructor.
    ConnectionGene(ConnectionGene _copy) {
        m_inNode = _copy.m_inNode;
        m_outNode = _copy.m_outNode;
        m_innovation = _copy.m_innovation;
        m_weight = _copy.m_weight;
        m_enabled = _copy.m_enabled;
    }

    // Mutate the weight between -1 and 1 of the connection gene 20% of the time.
    void mutateWeight() {
        if (random(1) < 0.2) { // Increased from 0.1 to 0.2
            m_weight = random(-1, 1);
        } else if (random(1) < 0.1) { // 10% chance for small perturbation
            m_weight += random(-0.2, 0.2);
        }

        //Sanity check - keep weight between bounds
        if(m_weight > 1){
            m_weight = 1;
        }
        if(m_weight < -1){
            m_weight = -1;      
        }
    }
}