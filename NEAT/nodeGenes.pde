// Define a class to represent node genes of the genotype
class NodeGene {

    int m_id = 0;
    int m_type = 0;

    // Node gene types
    static final int INPUT = 0;
    static final int HIDDEN = 1;
    static final int OUTPUT = 2;

    NodeGene(int _id, int _type) {
        m_id    = _id;
        m_type  = _type;
    }
 
    // Copy constructor
    NodeGene(NodeGene _node) {
        m_id    = _node.m_id;
        m_type  = _node.m_type;
    }
}