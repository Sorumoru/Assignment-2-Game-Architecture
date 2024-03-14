//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab10: Demo using Box2D for a ball that can be launched and
//        a falling brick that disappears when it hits the ball
//
//====================================================================

import SceneKit

import QuartzCore

class Arkanoid: SCNScene {
    
    var cameraNode = SCNNode()                      // Initialize camera node
    
    var lastTime = CFTimeInterval(floatLiteral: 0)  // Used to calculate elapsed time on each update
    
    private var box2D: CBox2D!                      // Points to Objective-C++ wrapper for C++ Box2D library
    
    private var xBound: Float = 65                  // Width (x-value) from center of screen (0,0)
    private var yBound: Float = 225                 // Height (y-value) from center of screen (0,0)
    private var paddleMoveSpeed: Float = 0.2
    
    private var numLives: Int = 3
    public var livesLeft: Int
    var livesLabel: UILabel!
    var gameView: ArkanoidView?
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    init(gameView: ArkanoidView) {
        self.livesLeft = numLives
        self.gameView = gameView
        gameView.updateLivesLabel(with: livesLeft)
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        
        // Add the ball and the brick
        addBall()
        addPaddle()
        addWalls()
        // Initialize the Box2D object
        box2D = CBox2D()
        //        box2D.helloWorld()  // If you want to test the HelloWorld example of Box2D
        // Setup the game loop tied to the display refresh
        let updater = CADisplayLink(target: self, selector: #selector(gameLoop))
        updater.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        updater.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        addBrickGrid()
    }

    
    // Function to setup the camera node
    func setupCamera() {
        // WARNING: do not change >:(
        let camera = SCNCamera() // Create Camera object
        camera.zFar = 1000
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 150
        cameraNode.camera = camera // Give the cameraNode a camera
        // Since this is 2D, just look down the z-axis
        cameraNode.position = SCNVector3(0, 100, 100)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
        
    }
    
    
    func addBrickGrid() {
        _ = [BrickPosition]()
        
        let spacing = Float(BRICK_SPACING)
        let brickWidth: Float = Float(BRICK_WIDTH)
        let brickHeight: Float = Float(BRICK_HEIGHT)
        
        let totalWidth = Float(NUM_COLUMNS) * brickWidth + Float(NUM_COLUMNS - 1) * spacing
        let totalHeight = Float(NUM_ROWS) * brickHeight + Float(NUM_ROWS - 1) * spacing
        
        let startX: Float = -(totalWidth / 2)
        let startY: Float = (totalHeight / 2) + 100
        
        for row in 0..<NUM_ROWS {
            for column in 0..<NUM_COLUMNS {
                let brick = SCNNode(geometry: SCNBox(width: CGFloat(brickWidth), height: CGFloat(brickHeight), length: 1, chamferRadius: 0))
                brick.name = "Brick (\(row), \(column))"
                brick.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                let brickPos = UnsafePointer(box2D.getObject(brick.name))
                //                let x = startX + Float(column) * (brickWidth + spacing)
                //                let y = startY - Float(row) * (brickHeight + spacing)
                brick.position.x = (brickPos?.pointee.loc.x)!
                brick.position.y = (brickPos?.pointee.loc.y)!
                //brick.position = SCNVector3(x, y, 0)
                
                //brickPositions.append(BrickPosition(x: x, y: y))
                
                rootNode.addChildNode(brick)
            }
        }
        //box2D.createBrickPhysics(brickPositions)
    }
    
    
    
    func addBall() {
        
        let theBall = SCNNode(geometry: SCNSphere(radius: CGFloat(BALL_RADIUS)))
        theBall.name = "Ball"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        theBall.position = SCNVector3(Int(BALL_POS_X), Int(BALL_POS_Y), 0)
        rootNode.addChildNode(theBall)
        
    }
    
    func addPaddle() {
        let paddleGeometry = SCNBox(width: CGFloat(PADDLE_WIDTH), height: CGFloat(PADDLE_HEIGHT), length: 1.0, chamferRadius: 0)
        let paddleNode = SCNNode(geometry: paddleGeometry)
        paddleNode.name = "Paddle"
        paddleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        paddleNode.position = SCNVector3(Int(BALL_POS_X), Int(BALL_POS_Y) - Int(2 * BALL_RADIUS), 0)
        rootNode.addChildNode(paddleNode)
    }
    
    func addWalls() {
        // Right wall
        let rightWall = SCNNode(geometry: SCNBox(width: CGFloat(WALL_THICKNESS), height: CGFloat(WALL_HEIGHT), length: 1.0, chamferRadius: 0))
        rightWall.name = "RightWall"
        rightWall.position = SCNVector3(xBound + WALL_THICKNESS / 2, WALL_Y_OFFSET, 0)
        rightWall.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        rootNode.addChildNode(rightWall)
        
        // Left wall
        let leftWall = SCNNode(geometry: SCNBox(width: CGFloat(WALL_THICKNESS), height: CGFloat(WALL_HEIGHT), length: 1.0, chamferRadius: 0))
        leftWall.name = "LeftWall"
        leftWall.position = SCNVector3(-xBound - WALL_THICKNESS / 2, WALL_Y_OFFSET, 0)
        leftWall.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        rootNode.addChildNode(leftWall)
        
        // Top wall
        let topWall = SCNNode(geometry: SCNBox(width: CGFloat(TOP_WALL_WIDTH), height: CGFloat(WALL_THICKNESS), length: 1.0, chamferRadius: 0))
        topWall.name = "TopWall"
        topWall.position = SCNVector3(0, yBound, 0)
        topWall.geometry?.firstMaterial?.diffuse.contents = UIColor.gray
        rootNode.addChildNode(topWall)
    }
    
    func decrementLives() {
        livesLeft -= 1
        gameView!.updateLivesLabel(with: livesLeft)
    }
    
    func resetLives() {
        livesLeft = numLives
        for row in 0..<NUM_ROWS {
            for column in 0..<NUM_COLUMNS {
                let brickName = "Brick (\(row), \(column))"
                let brickPos = UnsafePointer(box2D.getObject(brickName))
                let theBrick = rootNode.childNode(withName: brickName, recursively: true)
                theBrick?.isHidden = false
            }
        }
        gameView!.updateLivesLabel(with: livesLeft)
    }
    
    // Simple game loop that gets called each frame
    @MainActor
    @objc
    func gameLoop(displaylink: CADisplayLink) {
        
        if (lastTime != CFTimeInterval(floatLiteral: 0)) {  // if it's the first frame, just update lastTime
            let elapsedTime = displaylink.targetTimestamp - lastTime    // calculate elapsed time
            updateGameObjects(elapsedTime: elapsedTime) // update all the game objects
        }
        lastTime = displaylink.targetTimestamp
        
    }
    
    
    @MainActor
    func updateGameObjects(elapsedTime: Double) {
        
        // Update Box2D physics simulation
        box2D.update(Float(elapsedTime))
        
        // Ensure ball and paddle nodes exist
        guard let theBall = rootNode.childNode(withName: "Ball", recursively: true),
              let paddleNode = rootNode.childNode(withName: "Paddle", recursively: true),
              let rightWallNode = rootNode.childNode(withName: "RightWall", recursively: true),
              let leftWallNode = rootNode.childNode(withName: "LeftWall", recursively: true),
              let topWallNode = rootNode.childNode(withName: "TopWall", recursively: true) else {
            return
        }
        let ballPos = UnsafePointer(box2D.getObject("Ball"))
        
        if (box2D.ballLaunched)
        {
            // Get ball position and update ball node
            theBall.position.x = (ballPos?.pointee.loc.x)!
            theBall.position.y = (ballPos?.pointee.loc.y)!
        } else {
            // Move the ball with the paddle and set the box2D ball position directly
            theBall.position.x = paddleNode.position.x
            theBall.position.y = paddleNode.position.y + BALL_RADIUS * 2
            box2D.updateBallPosition(theBall.position.x, andY: theBall.position.y)
        }
        
        if (theBall.position.y < BALL_OUT_OF_BOUNDS_Y) {
            decrementLives()
            box2D.reset(Int32(livesLeft))
            if (livesLeft < 0) {
                resetLives()
            }
        }
        
        
        // Update paddle position to match its Box2D physics object
        let paddlePos = UnsafePointer(box2D.getObject("Paddle"))
        if let paddlePos = paddlePos {
            paddleNode.position.x = paddlePos.pointee.loc.x
            paddleNode.position.y = paddlePos.pointee.loc.y
        }
        
        gameView!.updateScoreLabel(with: Int(box2D.getScore()));
        
        for row in 0..<NUM_ROWS {
            for column in 0..<NUM_COLUMNS {
                let brickName = "Brick (\(row), \(column))"
                let brickPos = UnsafePointer(box2D.getObject(brickName))
                let theBrick = rootNode.childNode(withName: brickName, recursively: true)
                if (brickPos != nil) {
                    
                    // The brick is visible, so set the position
                    theBrick?.position.x = (brickPos?.pointee.loc.x)!
                    theBrick?.position.y = (brickPos?.pointee.loc.y)!
                    
                } else {
                    
                    // The brick has disappeared, so hide it
                    theBrick?.isHidden = true
                    
                }
            }
        }
    }
    
    
    // Function to be called by double-tap gesture: launch the ball
    @MainActor
    func handleDoubleTap() {
        
        box2D.launchBall()
        
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let paddleNode = rootNode.childNode(withName: "Paddle", recursively: true) else {
            return // Ensure paddle node exists
        }
        
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view)
        let translationX = Float(translation.x)
        
        // Calculate the new position of the paddle
        let newPositionX = paddleNode.position.x + translationX * paddleMoveSpeed
        
        // Set manual clamp values here
        let minX: Float = -xBound + PADDLE_WIDTH / 2
        let maxX: Float = xBound - PADDLE_WIDTH / 2
        
        // Clamp the new position within the manual clamp values
        let clampedPositionX = min(max(minX, newPositionX), maxX)
        
        // Apply the clamped position
        box2D.updatePaddlePosition(clampedPositionX)
        
        // Reset the translation of the gesture recognizer
        gestureRecognizer.setTranslation(.zero, in: gestureRecognizer.view)
    }
}

