// Shared obstacle manager for all dinos
class ObstacleManager {
    
    ArrayList<Obstacles> obstacles = new ArrayList<Obstacles>();
    
    int timerBetweenObstacles = 0;
    int minimumTimeBetweenObstacles = 80; // Reduced from 100 for more frequent obstacles
    int randomAdditionOfNewObstacles = floor(random(30)); // Reduced from 50 for more consistency
    
    float speed = 5;
    
    // Update obstacles and create new ones
    void update() {
        updateSpeed();
        addObstacle();
        updateObstacles();
    }
    
    // Display all obstacles
    void show() {
        for(int i = 0; i < obstacles.size(); i++) {
            obstacles.get(i).show();
        }
    }
    
    // Check collision with a dino at given position
    boolean checkCollision(float dinoX, float posY, boolean isCrouching) {
        float dinoY = posY + ((isCrouching) ? dinoDuck.height/2 : dinoRun1.height/2);
        float dinoWidth = dinoRun1.width * 0.5;
        float dinoHeight = dinoRun1.height;
        
        for(int i = 0; i < obstacles.size(); i++) {
            if(obstacles.get(i).isCollision(dinoX, dinoY, dinoWidth, dinoHeight)) {
                return true;
            }
        }
        return false;
    }
    
    // Get the closest obstacle ahead of a position
    Obstacles getClosestObstacle(float dinoX) {
        Obstacles closest = null;
        float closestDistance = Float.MAX_VALUE;
        
        for (Obstacles obstacle : obstacles) {
            if (obstacle.positionX > dinoX) { // Only consider obstacles ahead
                float distance = obstacle.positionX - dinoX;
                if (distance < closestDistance) {
                    closestDistance = distance;
                    closest = obstacle;
                }
            }
        }
        
        return closest;
    }
    
    // Get the second closest obstacle ahead of a position
    Obstacles getSecondClosestObstacle(float dinoX) {
        Obstacles closest = null;
        Obstacles secondClosest = null;
        float closestDistance = Float.MAX_VALUE;
        float secondClosestDistance = Float.MAX_VALUE;
        
        for (Obstacles obstacle : obstacles) {
            if (obstacle.positionX > dinoX) { // Only consider obstacles ahead
                float distance = obstacle.positionX - dinoX;
                if (distance < closestDistance) {
                    secondClosest = closest;
                    secondClosestDistance = closestDistance;
                    closest = obstacle;
                    closestDistance = distance;
                } else if (distance < secondClosestDistance) {
                    secondClosest = obstacle;
                    secondClosestDistance = distance;
                }
            }
        }
        
        return secondClosest;
    }
    
    // Reset obstacles (for new generation)
    void reset() {
        obstacles.clear();
        speed = 5;
        timerBetweenObstacles = 0;
        randomAdditionOfNewObstacles = floor(random(30)); // Updated to match new range
    }
    
    // Private methods
    private void updateSpeed() {
        speed += 0.005; // Increased from 0.001 to 0.005 for faster difficulty progression
    }
    
    private void updateObstacles() {
        for(int i = obstacles.size() - 1; i >= 0; i--) {
            obstacles.get(i).move(speed);
            
            if ((obstacles.get(i).positionX + obstacles.get(i).obstacleWidth) < 0) {
                obstacles.remove(i);
            }
        }
    }
    
    private void addObstacle() {
        // Increment the timer between obstacles
        timerBetweenObstacles += 1;

        // If enough time has passed, add a new obstacle
        if (timerBetweenObstacles > (minimumTimeBetweenObstacles + randomAdditionOfNewObstacles)) {
            Obstacles obstacle = new Obstacles(floor(random(6)));
            obstacles.add(obstacle);

            // Reset the timer and generate a new random time for the next obstacle
            timerBetweenObstacles = 0;
            randomAdditionOfNewObstacles = floor(random(30)); // Updated to match new range
        }
    }
}