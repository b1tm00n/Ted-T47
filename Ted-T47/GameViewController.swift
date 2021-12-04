//
//  GameViewController.swift
//  Ted-T47
//
//  Created by andy on 11/06/2021.
//  Copyright © 2021 Bluemoons. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard   let view = self.view as? SKView,
                let scene = SKScene(fileNamed: "GameScene") 
        else
        {
            assertionFailure("""
                             The game should flat out crash if the game view controller doesn't have a view or
                             if there isn't a scence. It's a requirement.
                             """)
            return
        }

        // Load the SKScene from 'GameScene.sks'
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
            
        // Present the scene
        view.presentScene(scene)
        
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
