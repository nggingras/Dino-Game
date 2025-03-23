#include <gtest/gtest.h>

#include "../src/Node.h"
#include "../src/Connection.h"

TEST(ConnectionTest, ConnectionInitialization) {
    Node nodeA(1);
    Node nodeB(2);
    Connection conn(&nodeA, &nodeB, 0.75, 1);

    EXPECT_EQ(conn.getFromNode(), &nodeA);
    EXPECT_EQ(conn.getToNode(), &nodeB);
    EXPECT_DOUBLE_EQ(conn.getWeight(), 0.75);
    EXPECT_TRUE(conn.isEnabled());
}

TEST(ConnectionTest, ConnectionDisabling) {
    Node nodeA(1);
    Node nodeB(2);
    Connection conn(&nodeA, &nodeB, 0.5, 0);

    EXPECT_FALSE(conn.isEnabled());
}
