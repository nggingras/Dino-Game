// Dino Game Class - JavaScript version of the Processing Dino game
class DinoGame {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        
        // Game state
        this.isRunning = false;
        this.isPaused = false;
        this.gameOver = false;
        
        // Dino properties (matching Processing code)
        this.posY = 0;
        this.velY = 0;
        this.gravity = 0.6;
        this.speed = 5;
        this.isCrouching = false;
        this.dinoDead = false;
        this.dinoX = 150;
        this.dinoWalk = 0;
        this.score = 0;
        
        // Obstacle management (matching Processing code)
        this.timerBetweenObstacles = 0;
        this.minimumTimeBetweenObstacles = 100;
        this.randomAdditionOfNewObstacles = Math.floor(Math.random() * 50);
        this.obstacles = [];
        
        // Ground height (matching Processing code)
        this.groundHeight = 250;
        
        // Load images
        this.loadImages();
        
        // AI control
        this.aiControl = false;
        this.neuralNetwork = null;
        
        // Animation frame
        this.animationId = null;
    }
    
    // Load game images
    loadImages() {
        this.images = {};
        this.imagesLoaded = 0;
        this.totalImages = 11;
        
        const imageFiles = {
            dinoRun1: 'assets/images/dinorun0000.png',
            dinoRun2: 'assets/images/dinorun0001.png',
            dinoJump: 'assets/images/dinoJump0000.png',
            dinoDuck: 'assets/images/dinoduck0000.png',
            dinoDuck1: 'assets/images/dinoduck0001.png',
            dinoDead: 'assets/images/dinoDead0000.png',
            smallCactus: 'assets/images/cactusSmall0000.png',
            bigCactus: 'assets/images/cactusBig0000.png',
            smallCactusMany: 'assets/images/cactusSmallMany0000.png',
            bird: 'assets/images/berd.png',
            bird1: 'assets/images/berd2.png'
        };
        
        // Load each image
        for (const [key, path] of Object.entries(imageFiles)) {
            this.images[key] = new Image();
            this.images[key].onload = () => {
                this.imagesLoaded++;
                if (this.imagesLoaded === this.totalImages) {
                    console.log('All images loaded successfully!');
                }
            };
            this.images[key].onerror = () => {
                console.error(`Failed to load image: ${path}`);
                // Fallback to placeholder
                this.images[key] = this.createPlaceholderImage(50, 50, '#333');
            };
            this.images[key].src = path;
        }
    }
    
    // Create placeholder images as fallback
    createPlaceholderImage(width, height, color) {
        const canvas = document.createElement('canvas');
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext('2d');
        ctx.fillStyle = color;
        ctx.fillRect(0, 0, width, height);
        return canvas;
    }
    
    // Start the game
    start() {
        this.isRunning = true;
        this.gameOver = false;
        this.score = 0;
        this.obstacles = [];
        this.timerBetweenObstacles = 0;
        this.speed = 5;
        this.dinoDead = false;
        this.posY = 0;
        this.velY = 0;
        this.isCrouching = false;
        this.gameLoop();
    }
    
    // Pause/unpause the game
    pause() {
        this.isPaused = !this.isPaused;
        if (!this.isPaused) {
            this.gameLoop();
        }
    }
    
    // Stop the game
    stop() {
        this.isRunning = false;
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
        }
    }
    
    // Main game loop
    gameLoop() {
        if (!this.isRunning || this.isPaused) return;
        
        this.update();
        this.render();
        
        if (!this.dinoDead) {
            this.animationId = requestAnimationFrame(() => this.gameLoop());
        } else {
            this.gameOver = true;
        }
    }
    
    // Update game state (matching Processing move() method)
    update() {
        this.updateSpeed();
        this.addObstacle();
        this.updateDinoPosition();
        this.updateObstacles();
        this.updateScore();
    }
    
    // Render game (matching Processing show() method)
    render() {
        // Clear canvas
        this.ctx.fillStyle = '#fff';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        // Draw ground line (matching Processing)
        this.ctx.strokeStyle = '#000';
        this.ctx.lineWidth = 2;
        this.ctx.beginPath();
        this.ctx.moveTo(0, this.canvas.height - this.groundHeight - 30);
        this.ctx.lineTo(this.canvas.width, this.canvas.height - this.groundHeight - 30);
        this.ctx.stroke();
        
        // Draw dino and obstacles
        this.drawDino();
        this.updateDinoWalk();
        this.displayObstacles();
    }
    
    // Draw the dino (matching Processing drawDino())
    drawDino() {
        if (this.dinoDead) {
            this.drawDeadDino();
        } else if (this.isCrouching) {
            this.drawCrouchingDino();
        } else {
            this.drawRunningDino();
        }
    }
    
    // Draw dead dino
    drawDeadDino() {
        const image = this.images.dinoDead;
        // Use the same size as running dino for consistency
        const targetWidth = this.images.dinoRun1 ? this.images.dinoRun1.width : 50;
        const targetHeight = this.images.dinoRun1 ? this.images.dinoRun1.height : 50;

        if (image && image.complete) {
            const y = this.canvas.height - this.groundHeight - (this.posY + targetHeight);
            this.ctx.drawImage(image, this.dinoX - targetWidth/2, y, targetWidth, targetHeight);
        } else {
            // Fallback to rectangle
            const y = this.canvas.height - this.groundHeight - (this.posY + 50);
            this.ctx.fillStyle = '#ff0000';
            this.ctx.fillRect(this.dinoX - 25, y, 50, 50);
        }
    }
    
    // Draw crouching dino (matching Processing drawCrouchingDino())
    drawCrouchingDino() {
        const image = this.dinoWalk < 0 ? this.images.dinoDuck : this.images.dinoDuck1;
        
        if (image && image.complete) {
            const y = this.canvas.height - this.groundHeight - (this.posY + image.height);
            this.ctx.drawImage(image, this.dinoX - image.width/2, y);
        } else {
            // Fallback to rectangle
            const y = this.canvas.height - this.groundHeight - (this.posY + 25);
            this.ctx.fillStyle = '#333';
            this.ctx.fillRect(this.dinoX - 25, y, 50, 25);
        }
    }
    
    // Draw running dino (matching Processing drawRunningDino())
    drawRunningDino() {
        let image;
        if (this.posY > 0) {
            // Dino is jumping
            image = this.images.dinoJump;
        } else {
            // Dino is running
            image = this.dinoWalk < 0 ? this.images.dinoRun1 : this.images.dinoRun2;
        }
        
        if (image && image.complete) {
            const y = this.canvas.height - this.groundHeight - (this.posY + image.height);
            this.ctx.drawImage(image, this.dinoX - image.width/2, y);
        } else {
            // Fallback to rectangle
            const y = this.canvas.height - this.groundHeight - (this.posY + 50);
            this.ctx.fillStyle = '#333';
            this.ctx.fillRect(this.dinoX - 25, y, 50, 50);
        }
    }
    
    // Update dino walk animation (matching Processing updateDinoWalk())
    updateDinoWalk() {
        this.dinoWalk++;
        if (this.dinoWalk > 10) {
            this.dinoWalk = -10;
        }
    }
    
    // Display obstacles (matching Processing displayObstacles())
    displayObstacles() {
        for (let i = 0; i < this.obstacles.length; i++) {
            this.obstacles[i].show(this.ctx, this.canvas.height, this.groundHeight);
        }
    }
    
    // Update speed (matching Processing updateSpeed())
    updateSpeed() {
        this.speed += 0.001;
    }
    
    // Update obstacles (matching Processing updateObstacles())
    updateObstacles() {
        for (let i = this.obstacles.length - 1; i >= 0; i--) {
            this.obstacles[i].move(this.speed);
            
            this.checkCollision(i);
            
            if ((this.obstacles[i].positionX + this.obstacles[i].obstacleWidth) < 0) {
                this.obstacles.splice(i, 1);
            }
        }
    }
    
    // Update dino position (matching Processing updateDinoPosition())
    updateDinoPosition() {
        this.posY += this.velY;
        
        if (this.posY > 0) {
            this.velY -= this.gravity;
        } else {
            this.velY = 0;
            this.posY = 0;
        }
    }
    
    // Check collision (matching Processing checkCollision())
    checkCollision(i) {
        const dinoHeight = this.isCrouching ? this.images.dinoDuck.height : this.images.dinoRun1.height;
        const dinoY = this.posY + dinoHeight/2;
        
        if (this.obstacles[i].isCollision(this.dinoX, dinoY, this.images.dinoRun1.width * 0.5, dinoHeight)) {
            this.dinoDead = true;
        }
    }
    
    // Update score (matching Processing updateScore())
    updateScore() {
        if (!this.dinoDead) {
            this.score++;
        }
    }
    
    // Add obstacle (matching Processing addObstacle())
    addObstacle() {
        this.timerBetweenObstacles += 1;
        
        if (this.timerBetweenObstacles > (this.minimumTimeBetweenObstacles + this.randomAdditionOfNewObstacles)) {
            const obstacle = new Obstacle(Math.floor(Math.random() * 6));
            this.obstacles.push(obstacle);
            
            this.timerBetweenObstacles = 0;
            this.randomAdditionOfNewObstacles = Math.floor(Math.random() * 50);
        }
    }
    
    // Handle input (matching Processing keyPressed/keyReleased)
    handleInput(key, pressed) {
        if (key === ' ' || key === 'ArrowUp') {
            if (pressed) {
                this.isCrouching = false;
                if (this.posY === 0) {
                    this.velY = 16;
                }
            }
        } else if (key === 'ArrowDown') {
            this.isCrouching = pressed;
        }
    }
    
    // AI control methods
    setNeuralNetwork(network) {
        this.neuralNetwork = network;
        this.aiControl = true;
    }
    
    // Get game state for AI input
    getGameState() {
        const nearestObstacle = this.getNearestObstacle();
        
        return {
            dinoY: this.posY,
            dinoVelocity: this.velY,
            obstacleX: nearestObstacle ? nearestObstacle.positionX : 1000,
            obstacleHeight: nearestObstacle ? nearestObstacle.obstacleHeight : 0,
            obstacleType: nearestObstacle ? nearestObstacle.type : 0
        };
    }
    
    // Get nearest obstacle for AI
    getNearestObstacle() {
        let nearest = null;
        let minDistance = Infinity;
        
        for (const obstacle of this.obstacles) {
            if (obstacle.positionX > this.dinoX && obstacle.positionX < minDistance) {
                nearest = obstacle;
                minDistance = obstacle.positionX;
            }
        }
        
        return nearest;
    }
    
    // Update AI control
    updateAI() {
        if (!this.aiControl || !this.neuralNetwork) return;
        
        const gameState = this.getGameState();
        const inputs = [
            gameState.dinoY / 100,  // Normalize
            gameState.dinoVelocity / 20,  // Normalize
            gameState.obstacleX / this.canvas.width,  // Normalize
            gameState.obstacleHeight / 120  // Normalize
        ];
        
        // Feed forward through neural network
        this.neuralNetwork.feedForward(inputs);
        const outputs = this.neuralNetwork.getOutputs();
        
        // Apply AI decision
        if (outputs[0] > 0.5) {
            this.handleInput(' ', true);
        } else if (outputs[1] > 0.5) {
            this.handleInput('ArrowDown', true);
        } else {
            this.handleInput('ArrowDown', false);
        }
    }
    
    // Check if game is over
    isDead() {
        return this.dinoDead;
    }
    
    // Get fitness for NEAT
    getFitness() {
        return this.score;
    }
    
    // Reset game state
    reset() {
        this.stop();
        this.start();
    }
}

// Obstacle class (matching Processing Obstacles class)
class Obstacle {
    constructor(type) {
        this.positionX = 1200; // Canvas width
        this.positionY = 0;
        this.obstacleWidth = 0;
        this.obstacleHeight = 0;
        this.type = type;
        this.birdFlapState = 0;
        
        // Obstacle types (matching Processing constants)
        this.SMALL_CACTUS = 0;
        this.SMALL_CACTUS_MANY = 1;
        this.BIG_CACTUS = 2;
        this.BIRD_LOW = 3;
        this.BIRD_MIDDLE = 4;
        this.BIRD_HIGH = 5;
        
        this.setObstacleSizeAndPosition();
    }
    
    // Set size and position (matching Processing setObstacleSizeAndPosition())
    setObstacleSizeAndPosition() {
        switch (this.type) {
            case this.SMALL_CACTUS:
            case this.SMALL_CACTUS_MANY:
                this.obstacleWidth = 40;
                this.obstacleHeight = 80;
                this.positionY = 0;
                break;
            case this.BIG_CACTUS:
                this.obstacleWidth = 60;
                this.obstacleHeight = 120;
                this.positionY = 0;
                break;
            case this.BIRD_LOW:
                this.obstacleWidth = 60;
                this.obstacleHeight = 50;
                this.positionY = 40;
                break;
            case this.BIRD_MIDDLE:
                this.obstacleWidth = 60;
                this.obstacleHeight = 50;
                this.positionY = 120;
                break;
            case this.BIRD_HIGH:
                this.obstacleWidth = 60;
                this.obstacleHeight = 50;
                this.positionY = 160;
                break;
        }
    }
    
    // Show obstacle (matching Processing show())
    show(ctx, canvasHeight, groundHeight) {
        ctx.fillStyle = '#000';
        this.drawObstacle(ctx, canvasHeight, groundHeight);
    }
    
    // Move obstacle (matching Processing move())
    move(speed) {
        this.positionX -= speed;
    }
    
    // Check collision (matching Processing isCollision())
    isCollision(dinoX, dinoY, dinoWidth, dinoHeight) {
        if (this.isXAxisCollision(dinoX, dinoWidth)) {
            if (this.isYAxisCollision(dinoY, dinoHeight)) {
                return true;
            }
        }
        return false;
    }
    
    // Draw obstacle (matching Processing drawObstacle())
    drawObstacle(ctx, canvasHeight, groundHeight) {
        if (this.type >= 3) {
            // Bird
            this.drawBird(ctx, canvasHeight, groundHeight);
        } else {
            // Cactus
            this.drawCactus(ctx, canvasHeight, groundHeight);
        }
    }
    
    // Draw cactus (matching Processing drawObstacle())
    drawCactus(ctx, canvasHeight, groundHeight) {
        let image;
        switch (this.type) {
            case this.SMALL_CACTUS:
                image = window.dinoApp?.game?.images?.smallCactus;
                break;
            case this.SMALL_CACTUS_MANY:
                image = window.dinoApp?.game?.images?.smallCactusMany;
                break;
            case this.BIG_CACTUS:
                image = window.dinoApp?.game?.images?.bigCactus;
                break;
            default:
                image = window.dinoApp?.game?.images?.smallCactus;
        }
        
        if (image && image.complete) {
            const y = canvasHeight - groundHeight - image.height;
            ctx.drawImage(image, this.positionX - image.width/2, y);
        } else {
            // Fallback to rectangle
            const y = canvasHeight - groundHeight - this.obstacleHeight;
            ctx.fillStyle = '#2d5a27';
            ctx.fillRect(this.positionX - this.obstacleWidth/2, y, this.obstacleWidth, this.obstacleHeight);
        }
    }
    
    // Draw bird (matching Processing drawBird())
    drawBird(ctx, canvasHeight, groundHeight) {
        let image;
        if (this.birdFlapState < 10) {
            image = window.dinoApp?.game?.images?.bird;
        } else {
            image = window.dinoApp?.game?.images?.bird1;
        }
        
        if (image && image.complete) {
            const y = canvasHeight - groundHeight - (this.positionY + image.height - 20);
            ctx.drawImage(image, this.positionX - image.width/2, y);
        } else {
            // Fallback to rectangle
            const y = canvasHeight - groundHeight - (this.positionY + 50 - 20);
            ctx.fillStyle = '#8b4513';
            ctx.fillRect(this.positionX - this.obstacleWidth/2, y, this.obstacleWidth, this.obstacleHeight);
        }
        
        this.birdFlapState++;
        if (this.birdFlapState > 20) {
            this.birdFlapState = 0;
        }
    }
    
    // X-axis collision check (matching Processing isXAxisCollision())
    isXAxisCollision(dinoX, dinoWidth) {
        const dinoLeft = dinoX - dinoWidth/2;
        const dinoRight = dinoX + dinoWidth/2;
        const obstacleLeft = this.positionX - this.obstacleWidth/2;
        const obstacleRight = this.positionX + this.obstacleWidth/2;
        return (dinoLeft <= obstacleRight && dinoRight >= obstacleLeft) || 
               (dinoRight >= obstacleLeft && dinoLeft <= obstacleRight);
    }
    
    // Y-axis collision check (matching Processing isYAxisCollision())
    isYAxisCollision(dinoY, dinoHeight) {
        const dinoBottom = dinoY - dinoHeight/2;
        const dinoTop = dinoY + dinoHeight/2;
        const obstacleTop = this.positionY + this.obstacleHeight/2;
        const obstacleBottom = this.positionY - this.obstacleHeight/2;
        return dinoBottom <= obstacleTop && dinoTop >= obstacleBottom;
    }
} 