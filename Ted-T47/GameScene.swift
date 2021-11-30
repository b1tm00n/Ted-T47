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
    
case ship = 1
case asteroid = 2
case bullet = 4

}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ship:SKSpriteNode = SKSpriteNode()
    let rotateRec = UIRotationGestureRecognizer()
    
    let tapRec = UITapGestureRecognizer()
    
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
            ship.physicsBody?.categoryBitMask = BodyType.ship.rawValue
            ship.physicsBody?.collisionBitMask = 0
            ship.physicsBody?.contactTestBitMask = BodyType.asteroid.rawValue
            
        }
        
        
        
        rotateRec.addTarget(self, action: #selector(GameScene.rotatedView(_:) ))
        self.view!.addGestureRecognizer(rotateRec)
        
        self.view!.isMultipleTouchEnabled = true
        self.view!.isUserInteractionEnabled = true
        
        tapRec.addTarget(self, action: #selector(GameScene.tappedView(_:) ))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
        
        halfWidth = self.frame.width / 2
        halfHeight = self.frame.height / 2
    
        createAsteroid()
    
    }
    
    func createAsteroid() {
        
        if (asteroidsInScene < maxAsteroids) {
            
           //
            
            var image:String = ""
            let i:Int = Int( arc4random_uniform(3) )
            
            switch i {
                case 0:
                    image = "Asteroid1"
                
                case 1:
                    image = "Asteroid2"
                
                default:
                    image = "Asteroid3"
                
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
        
        
        
        let touchPoint:CGPoint = sender.location(in: self.view )
        
        print( touchPoint.x )
        
        if (touchPoint.x > (self.view?.frame.width)! / 2 ){
            
            print("right side")
            boostShip()
        } else {
            
            print("left side")
            fire()
        }

        
    
    
    }
    func boostShip(){
        
        let xVec:CGFloat = sin(theRotation) * -10
        let yVec:CGFloat = cos(theRotation) * 10
        
        let theVector:CGVector = CGVector(dx: xVec, dy: yVec)
        
        ship.physicsBody?.applyImpulse(theVector)
    
    }
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
        
        if let scene = GameScene (fileNamed:"GameScene") {
            
            let transition:SKTransition = SKTransition.push(with: .right, duration: 1)
            self.view?.presentScene(scene, transition:transition )
        }
    }

}
