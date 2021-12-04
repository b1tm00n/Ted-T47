//
//  GameScene.swift
//  Ted-T47
//
//  Created by andy on 11/06/2021.
//  Copyright © 2021 Bluemoons. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BodyType:UInt32 {

// NOTE: (Ted)  Why are these cases powers of two? What happens if they aren't?
//              What sort of collision system would have to exist for such a thing
//              to be valuable?
case ship = 1
case asteroid = 2
case bullet = 4

}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ship:SKSpriteNode = SKSpriteNode()
    let rotateRec = UIRotationGestureRecognizer()
    
    var offset:CGFloat = 0
    let length:CGFloat = 200
    var theRotation:CGFloat = 0
    
    var halfWidth:CGFloat = 0
    var halfHeight:CGFloat = 0
    
    var asteroidClock:TimeInterval = 4
    var maxAsteroids:Int = 10
    var asteroidsInScene:Int = 0
    var asteroidsShot:Int = 0
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
       
        if let someShip:SKSpriteNode = self.childNode(withName: "Ship") as? SKSpriteNode {
            
            ship = someShip

            // NOTE:(Ted)   Here's another place where physicsBody need not be an optional.
            //              You can set one up first, and then set it as a property.
            ship.physicsBody?.categoryBitMask = BodyType.ship.rawValue
            ship.physicsBody?.collisionBitMask = 0
            ship.physicsBody?.contactTestBitMask = BodyType.asteroid.rawValue
            
        }
        
        rotateRec.addTarget(self, action: #selector(GameScene.rotatedView(_:) ))
        
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: #selector(GameScene.tappedView(_:) ))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1

        if let sceneView = self.view
        {
            sceneView.addGestureRecognizer(tapRec)
            sceneView.addGestureRecognizer(rotateRec)
            sceneView.isMultipleTouchEnabled = true
            sceneView.isUserInteractionEnabled = true
        } else
        {
            assertionFailure("For some reason the scene doesn't have a view, and this is required in order to run the game")
        }
        
        halfWidth = self.frame.width / 2
        halfHeight = self.frame.height / 2
    
        createAsteroid()
    }
    
    func createAsteroid() {
        
        if (asteroidsInScene < maxAsteroids) {
            
            var image:String = ""
            let i:Int = Int( arc4random_uniform(3) )
       
            // NOTE: (Ted)  Again, this just makes it so you only need to make this change in one place.
            //              If you ever need to change it in the future.
            let namePrefix = "Asteroid"

            switch i {
                case 0:
                    image = "\(namePrefix)1"
                
                case 1:
                    image = "\(namePrefix)2"
                
                default:
                    image = "\(namePrefix)3"
                
            }

            let newAsteroid:Asteroid = Asteroid(imageNamed: image)
            newAsteroid.halfWidth = halfWidth
            newAsteroid.halfHeight = halfHeight
            
            if ( asteroidsShot > 3){
                
                newAsteroid.baseSpeed = CGFloat(asteroidsShot)
            }
            
            newAsteroid.setUp()
            self.addChild(newAsteroid)
        
        
        }
    

        let wait:SKAction = SKAction.wait(forDuration: asteroidClock)
        let create:SKAction = SKAction.run {
            
            self.createAsteroid()
        }
        let seq:SKAction = SKAction.sequence( [wait, create]  )
        self.run(seq)
    
    
    }

    
    // NOTE: (Ted)  When running this game, I noticed that after rotating the screen,
    //              the ship sometimes stretches to fill the aspect ratio of the screen
    //              at the new orientation. It's worth looking into a fix for that.
    @objc func rotatedView(_ sender:UIRotationGestureRecognizer){
        
        if (sender.state == .began) {
            
            // do anything you want when the rotation gesture has begun
            print("we began")
        
        }
        if ( sender.state == .changed) {
            print("we rotated")
            
            theRotation = CGFloat(sender.rotation) + self.offset
            theRotation = theRotation * -1
            
            ship.zRotation = theRotation
            
        }
        if (sender.state == .ended) {
            
            print("we ended")
            self.offset = theRotation * -1
            
        }
    
    }
    
    
    @objc func tappedView(_ sender:UITapGestureRecognizer){
        
        guard let view = self.view else
        {
            assertionFailure("It's impossible to respond to a tap if this has no view")
            return
        }
        
        let touchPoint:CGPoint = sender.location(in: view )
        
        print( touchPoint.x )
        
        if (touchPoint.x > (view.frame.width/2) ){
            
            print("right side")
            boostShip()
        } else {
            
            print("left side")
            fire()
        }
    
    }

    // NOTE: (Ted)  It's common to split something like this out and make it a function.
    //              I'm not saying it's necessarily a bad thing to do, but ask yourself this.
    //              Does anything call this function more than once? Would it affect the app in
    //              any negative way to just have this logic inline up in the tappedView function?
    //
    //              Is the abstraction of a function really needed?
    func boostShip(){
       
        guard let physicsBody = ship.physicsBody else
        {
            assertionFailure("The game shouldn't run if no physics body is set on the ship")
            return
        }

        let xVec:CGFloat = sin(theRotation) * -10
        let yVec:CGFloat = cos(theRotation) * 10
        
        let theVector:CGVector = CGVector(dx: xVec, dy: yVec)
        physicsBody.applyImpulse(theVector)
    
    }

    // TODO: (Ted)  It seems to me that it's a basic requirement that the bullet
    //              have a physics body. Can you make the app respond appropriately
    //              for the unusual circumstance in which it does not?
    func fire(){
    
        let xOffset:CGFloat = sin(theRotation) * -60
        let yOffset:CGFloat = cos(theRotation) * 60
        
        let newBullet:Bullet = Bullet(imageNamed: "Bullet")
        newBullet.setUp()
        newBullet.position = CGPoint(x:ship.position.x + xOffset, y:ship.position.y + yOffset)
        self.addChild(newBullet)
 
        let xVec:CGFloat = sin(theRotation) * -5
        let yVec:CGFloat = cos(theRotation) * 5
        
        let theVector:CGVector = CGVector(dx: xVec, dy: yVec)
        
        newBullet.physicsBody?.applyImpulse(theVector)
    }
   
    // NOTE: (Ted)  Having seen both mine and Casey's videos on 2D game engine development,
    //              where do you think this function would have to be called? Clearly, something is calling it.
    //              How was that thing setup? What does it need to do before this function is called and after
    //              it is called?
    //
    //              What is the currentTime, and what does it represent? What is the average time interval between
    //              one currentTime called in one update vs. the next one called in the next update? What is that tied to?
    override func update(_ currentTime: TimeInterval) {

        if (ship.position.x < -halfWidth){
            
            ship.position = CGPoint(x: halfWidth, y:ship.position.y )
        }
        else if (ship.position.x > halfWidth){
            
            ship.position = CGPoint(x: -halfWidth, y:ship.position.y )
            
        } else if (ship.position.y < -halfHeight){
            
            ship.position = CGPoint(x: ship.position.x, y:halfHeight )
        }
        else if (ship.position.y > halfHeight){
            
            ship.position = CGPoint(x: ship.position.x, y:-halfHeight )
        }
        
        asteroidsInScene = 0
        
        for node in self.children {
            

            if let someBullet:Bullet = node as? Bullet {
                
                if (someBullet.position.x < -halfWidth || someBullet.position.x > halfWidth){
                    
                    print("remove bullet")
                    someBullet.removeFromParent()
                } else if (someBullet.position.y < -halfHeight || someBullet.position.y > halfHeight){
                    
                
                    print("remove bullet")
                    someBullet.removeFromParent()
                }
                
            } else if let someAsteroid:Asteroid = node as? Asteroid {
                
                asteroidsInScene += 1
                
                someAsteroid.update()
               
                // NOTE: (Ted)  70 is clearly an important number. Can you factor it out into a constant so you
                //              only need to change it in one place?
                if (someAsteroid.position.x < -halfWidth - 70){
                    
                    someAsteroid.position = CGPoint(x: halfWidth + 70, y:someAsteroid.position.y )
                }
                else if (someAsteroid.position.x > halfWidth + 70){
                    
                    someAsteroid.position = CGPoint(x: -halfWidth - 70, y:someAsteroid.position.y )
                    
                } else if (someAsteroid.position.y < -halfHeight - 70){
                    
                    someAsteroid.position = CGPoint(x: someAsteroid.position.x, y:halfHeight + 70)
                }
                else if (someAsteroid.position.y > halfHeight + 70){
                    
                    someAsteroid.position = CGPoint(x: someAsteroid.position.x, y:-halfHeight - 70)
                }
                
            }
            
        }
        
        // Called before each frame is rendered
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
      if let touchedBody:SKPhysicsBody = self.physicsWorld.body(at: pos){
            
            if let theSprite:SKSpriteNode = touchedBody.node as? SKSpriteNode{
                
                print (theSprite)
            
            }
       
        }
        
     }
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }

    }
   
    // NOTE: (Ted)  Having seen my videos and Casey's, where in the series of events in a standard game loop might a function like this one get called?
    //              What calls it? Does it happen before the update, after it, or perhaps as a part of it? How do you know?
    func didBegin(_ contact: SKPhysicsContact) {
        
        //asteroid colliding with bullet
        
        if (contact.bodyA.categoryBitMask == BodyType.asteroid.rawValue && contact.bodyB.categoryBitMask == BodyType.bullet.rawValue){
            
            if let theAsteroid = contact.bodyA.node as? Asteroid {
                
                theAsteroid.removeFromParent()
            }
            
            asteroidsShot += 1
        
        }else if (contact.bodyA.categoryBitMask == BodyType.bullet.rawValue && contact.bodyB.categoryBitMask == BodyType.asteroid.rawValue){
    
            if let theAsteroid = contact.bodyB.node as? Asteroid {
                
                theAsteroid.removeFromParent()
            }
            
            asteroidsShot += 1
        }
        
        else if (contact.bodyA.categoryBitMask == BodyType.ship.rawValue && contact.bodyB.categoryBitMask == BodyType.asteroid.rawValue){
            
            ship.removeFromParent()
            self.loseGame()
            
        }
            
        else if (contact.bodyA.categoryBitMask == BodyType.asteroid.rawValue && contact.bodyB.categoryBitMask == BodyType.ship.rawValue){
            
            ship.removeFromParent()
            self.loseGame()
            
        }

    }
    
    func loseGame(){
        
        if  let scene = GameScene (fileNamed:"GameScene"), 
            let view = self.view
        {
            
            let transition:SKTransition = SKTransition.push(with: .right, duration: 1)
            view.presentScene(scene, transition:transition )
        } else
        {
            assertionFailure("If there is no game scene file, the game shouldn't run")
        }
    }
}
