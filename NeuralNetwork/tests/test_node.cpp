#include <gtest/gtest.h>

#include "../src/Node.h"
#include "../src/Connection.h"

TEST(NodeTest, NodeInitialization) {
    Node node(1, 0.3);
    EXPECT_EQ(node.getNodeId(), 1);
    EXPECT_DOUBLE_EQ(node.getBias(), 0.3);
    EXPECT_EQ(node.getNumInputConnections(), 0);
}

TEST(NodeTest, NodeActivation) {
    Node inputNode(1);
    inputNode.setOutputValue(1.0); // Simulate an input node

    Node hiddenNode(2, 0.5);
    Connection conn(&inputNode, &hiddenNode, 0.8, 1);
    hiddenNode.addInputConnection(&conn);

    hiddenNode.activate();

    double expectedOutput = 1.0 * 0.8 + 0.5;  // Weighted sum
    expectedOutput = 1.0 / (1.0 + exp(-expectedOutput)); // Sigmoid

    EXPECT_NEAR(hiddenNode.getOutputValue(), expectedOutput, 1e-6);
}