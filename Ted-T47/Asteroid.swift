//
//  Asteroids.swift
//  Ted-T47
//
//  Created by andy on 12/08/2021.
//  Copyright © 2021 Bluemoons. All rights reserved.
//

import Foundation

import SpriteKit

// NOTE: (Ted)  I've left some questions to get you thinking a little more deeply about this.
//
//              
class Asteroid:SKSpriteNode {
   
    //  NOTE: (Ted)
    //  Where do the following five variables live in memory? How are they represented?
    //  What, exactly, is a CGFloat? Could it be represented in a lower-level language like C?
    var halfWidth:CGFloat = 0
    var halfHeight:CGFloat = 0
    
    var xMovement:CGFloat = 0
    var yMovement:CGFloat = 0
    
    var baseSpeed:CGFloat = 2
   
    //  NOTE: (Ted)
    //
    //  Why is this function nested inside of the Asteroid class? Why is there an Asteroid class?
    //  What does that mean?
    //
    //
    //  Could the same thing be achieved without the notion Asteroid *class*? 
    //  How might that be accomplished?
    func setUp() {
        
        // NOTE: (Ted)  Good reuse of common logic. This is very much in line with the kind of thing
        //              Casey talks about with compression oriented programming.
        xMovement = randomBetweenNumbers(firstNum: -baseSpeed, secondNum: baseSpeed)
        yMovement = randomBetweenNumbers(firstNum: -baseSpeed, secondNum: baseSpeed)
        
        let randomNum:Int = Int(arc4random_uniform(4))
        
        var xPos:CGFloat = 0
        var yPos:CGFloat = 0
        
        switch randomNum {
        case 0:
            // NOTE: (Ted)  69 seems to be a commonly repeated pattern number. What does is represent?
            //              I usually make a #define or a constant variable out of these because
            //              then you only have to change it in one place.
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
       
        // NOTE: (Ted)  I made a few changes here. The big one was to remove the optionality of physics body.
        //              Generally (although is isn't always applicable), if you have a lot of lines with 
        //              question marks (a.k.a. optionality) after a variable, it usually means you aren't
        //              taking advantage of something you know.
        //
        //              In this case, you know you have an instance of SKPhysicsBody because you're the one who
        //              ran the initializer.
        //
        //              So why not modify the properties of the thing you know you have, and then when you're done,
        //              set that thing as the property of the Asteroid instance? At each step, you know you have the
        //              physics body. You don't need to check if you have it when you set one of its properties.
        if let someTex:SKTexture = self.texture 
        {
            let physicsBody = SKPhysicsBody(texture: someTex, size: someTex.size())
            physicsBody.affectedByGravity = false
            physicsBody.allowsRotation = false
            physicsBody.isDynamic = true
            physicsBody.categoryBitMask = BodyType.asteroid.rawValue
            physicsBody.collisionBitMask = BodyType.asteroid.rawValue
            physicsBody.contactTestBitMask = BodyType.ship.rawValue | BodyType.bullet.rawValue
            self.physicsBody = physicsBody 
        } else
        {
            // NOTE: (Ted)  I always use assertion failures whenever my apps hit a condition where they flat
            //              out shouldn't run.
            //
            //              This is one of those conditions.
            //
            //              You tried to call "setup," but you didn't have the texture set. That's a requirement.
            //              If the game tries to run with a texture-less asteroid, you won't see the asteroid, and your
            //              player can't play the game.
            //
            //              On debug builds, assertion failures will crash. They won't crash on production builds.
            //              That means when you run in debug mode, you can quickly find the cause of the problem in the debugger.
            //              But on a production build, nothing will happen, and the app will attempt to run without crashing.
            //              It's a nice compromise between two behaviors.
            assertionFailure("No asteroid can be setup without a texture")
        }
    }
    
    func update() {
        self.position = CGPoint(x: self.position.x + xMovement, y: self.position.y + yMovement)
        
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum,secondNum)
    }

}
