//
//  Asteroids.swift
//  Ted-T47
//
//  Created by andy on 12/08/2021.
//  Copyright © 2021 Bluemoons. All rights reserved.
//

import Foundation

import SpriteKit


class Asteroid:SKSpriteNode {
    
    var halfWidth:CGFloat = 0
    var halfHeight:CGFloat = 0
    
    var xMovement:CGFloat = 0
    var yMovement:CGFloat = 0
    
    var baseSpeed:CGFloat = 2
    
    func setUp() {
        
        xMovement = randomBetweenNumbers(firstNum: -baseSpeed, secondNum: baseSpeed)
        yMovement = randomBetweenNumbers(firstNum: -baseSpeed, secondNum: baseSpeed)
        
        let randomNum:Int = Int(arc4random_uniform(4))
        
        var xPos:CGFloat = 0
        var yPos:CGFloat = 0
        
        switch randomNum {
        case 0:
            xPos = -halfWidth - 69
            yPos = randomBetweenNumbers(firstNum: -halfHeight, secondNum: halfHeight)
            
        case 1:
            xPos = halfWidth + 69
            yPos = randomBetweenNumbers(firstNum: -halfHeight, secondNum: halfHeight)
            
        case 2:
            xPos = randomBetweenNumbers(firstNum: -halfWidth, secondNum: halfWidth)
            yPos = -halfHeight - 69
            
        default:
            xPos = randomBetweenNumbers(firstNum: -halfWidth, secondNum: halfWidth)
            yPos = -halfHeight + 69
        }
        
        self.position = CGPoint(x:xPos, y:yPos)
        
        if let someTex:SKTexture = self.texture {
            
            self.physicsBody = SKPhysicsBody(texture: someTex, size: someTex.size() )
            self.physicsBody?.affectedByGravity = false
            self.physicsBody?.allowsRotation = false
            self.physicsBody?.isDynamic = true
            
            self.physicsBody?.categoryBitMask = BodyType.asteroid.rawValue
            self.physicsBody?.collisionBitMask = BodyType.asteroid.rawValue
            self.physicsBody?.contactTestBitMask = BodyType.ship.rawValue | BodyType.bullet.rawValue
            
            }
        

  
    }
    
    func update() {
        
        
        self.position = CGPoint(x: self.position.x + xMovement, y: self.position.y + yMovement)
        
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum,secondNum)
    }

}
