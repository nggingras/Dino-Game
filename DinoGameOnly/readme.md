# Dino Class

The `Dino` class represents a dinosaur character in a game. It has the following structure:

## Properties

- `posY`: float - The vertical position of the Dino.
- `velY`: float - The vertical velocity of the Dino.
- `gravity`: float - The gravity affecting the Dino.
- `speed`: float - The speed of the Dino.
- `isCrouching`: boolean - Whether the Dino is crouching.
- `dinoDead`: boolean - Whether the Dino is dead.
- `dinoX`: int - The horizontal position of the Dino.
- `dinoWalk`: int - The Dino's walking state.
- `score`: int - The player's score.
- `timerBetweenObstacles`: int - The timer between obstacles.
- `minimumTimeBetweenObstacles`: int - The minimum time between obstacles.
- `randomAdditionOfNewObstacles`: int - The random time addition for the next obstacle.
- `obstacles`: ArrayList<Obstacles> - The list of obstacles.

## Public Methods

- `Dino()`: Constructor - Initializes a new instance of the Dino class.
- `show()`: void - Displays the Dino and obstacles.
- `move()`: void - Moves the Dino and obstacles.
- `isDead()`: boolean - Checks if the Dino is dead.

## Private Methods

- `drawDino()`: void - Draws the Dino.
- `drawCrouchingDino()`: void - Draws the Dino in a crouching state.
- `drawRunningDino()`: void - Draws the Dino in a running state.
- `updateDinoWalk()`: void - Updates the Dino's walking state.
- `displayObstacles()`: void - Displays the obstacles.
- `updateSpeed()`: void - Updates the speed of the game.
- `updateObstacles()`: void - Updates the obstacles.
- `updateDinoPosition()`: void - Updates the Dino's position.
- `checkCollision(int)`: void - Checks for a collision between the Dino and an obstacle.
- `updateScore()`: void - Updates the score.
- `addObstacle()`: void - Adds a new obstacle.




# Obstacles Class

The `Obstacles` class represents an obstacle in the game. It has the following structure:

## Properties

- `positionX`: float - The horizontal position of the obstacle.
- `positionY`: float - The vertical position of the obstacle.
- `obstacleWidth`: int - The width of the obstacle.
- `obstacleHeight`: int - The height of the obstacle.
- `type`: int - The type of the obstacle.
- `birdFlapState`: int - The bird's flap state.

## Constants

- `SMALL_CACTUS`: int - Represents a small cactus.
- `SMALL_CACTUS_MANY`: int - Represents multiple small cacti.
- `BIG_CACTUS`: int - Represents a big cactus.
- `BIRD_LOW`: int - Represents a low-flying bird.
- `BIRD_MIDDLE`: int - Represents a mid-flying bird.
- `BIRD_HIGH`: int - Represents a high-flying bird.

## Public Methods

- `Obstacles(int)`: Constructor - Initializes a new instance of the Obstacles class.
- `show()`: void - Displays the obstacle.
- `move(float)`: void - Moves the obstacle.
- `isCollision(float, float, float, float)`: boolean - Checks if the obstacle collided with the Dino.

## Private Methods

- `setObstacleSizeAndPosition()`: void - Sets the size and position based on the obstacle type.
- `drawObstacle()`: void - Draws the obstacle based on its type.
- `drawBird()`: void - Draws the bird obstacle.
- `isXAxisCollision(float, float)`: boolean - Checks if there is a collision on the x-axis.
- `isYAxisCollision(float, float)`: boolean - Checks if there is a collision on the y-axis.
