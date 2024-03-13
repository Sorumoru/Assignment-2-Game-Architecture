//
//  GameViewController.swift
//  Game-Architecture-Assignment-3
//
//  Created by Jun Solomon on 2024-03-08.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var scene: Arkanoid!
    var livesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add the ArkanoidView to the view controller's view
        let arkanoidView = ArkanoidView()
        arkanoidView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arkanoidView)
        
        // create a new scene
        scene = Arkanoid(gameView: arkanoidView)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        scnView.addGestureRecognizer(tapGesture)
        
        // Add pan gesture recognizer for paddle movement
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        scene.handleDoubleTap()
    }
    
    @objc
        func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        scene.handlePanGesture(gestureRecognizer)
    }
}
