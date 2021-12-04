//
//  Bullet.swift
//  Ted-T47
//
//  Created by andy on 31/07/2021.
//  Copyright © 2021 Bluemoons. All rights reserved.
//

import Foundation
import SpriteKit

class Bullet:SKSpriteNode {

    // TODO: (Ted)  Do a similar transformation like what I did with the Asteroid class.
    //              You know you have the physics body. Set it up first, and then set it as
    //              a property of this instance (self).
    func setUp() {
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.frame.size.width / 2)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.isDynamic = true
        
        self.physicsBody?.categoryBitMask = BodyType.bullet.rawValue
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.contactTestBitMask = BodyType.asteroid.rawValue
        
    }

}
