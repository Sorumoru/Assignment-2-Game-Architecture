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
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    override init() {
        
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        seeCenter()
        // Add the ball and the brick
        addBall()
        addBrickGrid(rows: 5, columns: 7, spacing: 1)
        
        // Initialize the Box2D object
        box2D = CBox2D()
        //        box2D.helloWorld()  // If you want to test the HelloWorld example of Box2D
        
        // Setup the game loop tied to the display refresh
        let updater = CADisplayLink(target: self, selector: #selector(gameLoop))
        updater.preferredFrameRateRange = CAFrameRateRange(minimum: 120.0, maximum: 120.0, preferred: 120.0)
        updater.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
        
    }
    
    
    func seeCenter() {
        let theBall = SCNNode(geometry: SCNSphere(radius: 1))
        theBall.name = "Ball2"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        theBall.position = SCNVector3(0, 0, 0)
        rootNode.addChildNode(theBall)
        let theBall3 = SCNNode(geometry: SCNSphere(radius: 1))
        theBall3.name = "Ball3"
        theBall3.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        theBall3.position = SCNVector3(5, 0, 0)
        rootNode.addChildNode(theBall3)
        let theBall4 = SCNNode(geometry: SCNSphere(radius: 1))
        theBall4.name = "Ball4"
        theBall4.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        theBall4.position = SCNVector3(0, 5, 0)
        rootNode.addChildNode(theBall4)
        let theBall5 = SCNNode(geometry: SCNSphere(radius: 1))
        theBall5.name = "Ball5"
        theBall5.geometry?.firstMaterial?.diffuse.contents = UIColor.purple
        theBall5.position = SCNVector3(0, 0, 5)
        rootNode.addChildNode(theBall5)
    }
    
    // Function to setup the camera node
    func setupCamera() {
        
        let camera = SCNCamera() // Create Camera object
        camera.zFar = 1000
        cameraNode.camera = camera // Give the cameraNode a camera
        // Since this is 2D, just look down the z-axis
        cameraNode.position = SCNVector3(0, 50, 200)
        cameraNode.eulerAngles = SCNVector3(0, 0, 0)
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
        
    }
    
    
    func addBrickGrid(rows: Int, columns: Int, spacing: Float) {
        let brickWidth: Float = Float(BRICK_WIDTH)
        let brickHeight: Float = Float(BRICK_HEIGHT)
        
        let totalWidth = Float(columns) * brickWidth + Float(columns - 1) * spacing
        let totalHeight = Float(rows) * brickHeight + Float(rows - 1) * spacing
        
        let startX: Float = -(totalWidth / 2)
        let startY: Float = (totalHeight / 2) + 100
        
        for row in 0..<rows {
            for column in 0..<columns {
                let brick = SCNNode(geometry: SCNBox(width: CGFloat(brickWidth), height: CGFloat(brickHeight), length: 1, chamferRadius: 0))
                brick.name = "Brick \(row)\(column)"
                brick.geometry?.firstMaterial?.diffuse.contents = UIColor.red
                
                let x = startX + Float(column) * (brickWidth + spacing)
                let y = startY - Float(row) * (brickHeight + spacing)
                
                brick.position = SCNVector3(x, y, 0)
                rootNode.addChildNode(brick)
            }
        }
    }

    
    
    func addBall() {
        
        let theBall = SCNNode(geometry: SCNSphere(radius: CGFloat(BALL_RADIUS)))
        theBall.name = "Ball"
        theBall.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        theBall.position = SCNVector3(Int(BALL_POS_X), Int(BALL_POS_Y), 0)
        rootNode.addChildNode(theBall)
        
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
        
        // Get ball position and update ball node
        let ballPos = UnsafePointer(box2D.getObject("Ball"))
        let theBall = rootNode.childNode(withName: "Ball", recursively: true)
        theBall?.position.x = (ballPos?.pointee.loc.x)!
        theBall?.position.y = (ballPos?.pointee.loc.y)!
        //        print("Ball pos: \(String(describing: theBall?.position.x)) \(String(describing: theBall?.position.y))")
        
        // Get brick position and update brick node
//        let brickPos = UnsafePointer(box2D.getObject("Brick"))
//        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
//        if (brickPos != nil) {
//            
//            // The brick is visible, so set the position
//            theBrick?.position.x = (brickPos?.pointee.loc.x)!
//            theBrick?.position.y = (brickPos?.pointee.loc.y)!
//            //            print("Brick pos: \(String(describing: theBrick?.position.x)) \(String(describing: theBrick?.position.y))")
//            
//        } else {
//            
//            // The brick has disappeared, so hide it
//            theBrick?.isHidden = true
//            
//        }
        
    }
    
    
    // Function to be called by double-tap gesture: launch the ball
    @MainActor
    func handleDoubleTap() {
        
        box2D.launchBall()
        
    }
    
    
    // Function to reset the physics (reset Box2D and reset the brick)
    @MainActor
    func resetPhysics() {
        
        box2D.reset()
        let theBrick = rootNode.childNode(withName: "Brick", recursively: true)
        theBrick?.isHidden = false
        
    }
    
}

