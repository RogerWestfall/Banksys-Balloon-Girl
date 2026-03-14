//
//  GameScene.swift
//  Banksy's Balloon Girl
//
//  Created by Roger Westfall on 11/25/16.
//  Copyright © 2016 Roger Westfall. All rights reserved.
//

import SpriteKit
import GameplayKit

//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Roger Westfall on 11/22/16.
//  Copyright © 2016 Roger Westfall. All rights reserved.
//

import SpriteKit


//Physics

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let parachutingRatRight   : UInt32 = 0b1       // 1
    static let Balloon: UInt32 = 0b10      // 2
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

let balloonPopSound = SKAudioNode(fileNamed: "balloonPop.wav")


class GameScene: SKScene, SKPhysicsContactDelegate {
   
//scoreLabel
    var scoreLabel: SKLabelNode!
    
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
// girl
    let girl = SKSpriteNode(imageNamed: "girl")
    
    override func didMove(to view: SKView) {
        // backgroundColor =  SKColor.lightGray
        let background = SKSpriteNode(imageNamed: "backgroundHills")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0 //backmost layer
        self.addChild(background)

        
        girl.position = CGPoint(x: size.width * 0.2, y: size.height * 0.1)
        girl.setScale(0.2)
        girl.zPosition = 4

        addChild(girl)

   
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addparachutingRatRight),
                SKAction.wait(forDuration: 1.0)
                ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "Wind.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 5.0, y: 625)
        scoreLabel.zPosition = 1
        addChild(scoreLabel)
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
// Parachuting Rat Right
    func addparachutingRatRight() {
        
        // Create sprite
        let parachutingRatRight = SKSpriteNode(imageNamed: "parachutingRatRight")
        
        // Determine where to spawn the parachutingRatRight along the Y axis
        // let actualY = random(min: parachutingRatRight.size.height/2, max: size.height - parachutingRatRight.size.height/2)
        let actualX = random(min: parachutingRatRight.size.width/5.0, max: size.width - parachutingRatRight.size.width/10.0)
        
        // Position the parachutingRatRight slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        parachutingRatRight.position = CGPoint(x: actualX, y: size.height + parachutingRatRight.size.height/2)
        
        // Add the parachutingRatRight to the scene
        addChild(parachutingRatRight)
        
        parachutingRatRight.setScale(0.15)
        parachutingRatRight.zPosition = 2
        
        parachutingRatRight.physicsBody = SKPhysicsBody(rectangleOf: parachutingRatRight.size) // 1
        parachutingRatRight.physicsBody?.isDynamic = true // 2
        parachutingRatRight.physicsBody?.categoryBitMask = PhysicsCategory.parachutingRatRight // 3
        parachutingRatRight.physicsBody?.contactTestBitMask = PhysicsCategory.Balloon // 4
        parachutingRatRight.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine speed of the parachutingRatRight
        let actualDuration = random(min: CGFloat(8.0), max: CGFloat(10.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -parachutingRatRight.size.height/2), duration: TimeInterval(actualDuration))
        let loseAction = SKAction.run() {
            let reveal = SKTransition.fade(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        parachutingRatRight.run(SKAction.sequence([actionMove, loseAction, actionMove]))
        
        
        
        
        
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        let balloon = SKSpriteNode(imageNamed: "balloon")
        balloon.position = CGPoint(x: size.width * 0.2, y: size.height * 0.2)
        balloon.zPosition = 2
        
        
        balloon.physicsBody = SKPhysicsBody(circleOfRadius: #imageLiteral(resourceName: "balloon").size.width/5)
        balloon.physicsBody?.isDynamic = true
        balloon.physicsBody?.categoryBitMask = PhysicsCategory.Balloon
        balloon.physicsBody?.contactTestBitMask = PhysicsCategory.parachutingRatRight
        balloon.physicsBody?.collisionBitMask = PhysicsCategory.None
        balloon.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - balloon.position
        
        // 4 - Bail out if you are shooting down or backwards
        if (offset.y < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(balloon)
        balloon.setScale(0.2)

        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + balloon.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 8.0)
        let actionMoveDone = SKAction.removeFromParent()
        balloon.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    func projectileDidCollideWithparachutingRatRight(balloon: SKSpriteNode, parachutingRatRight: SKSpriteNode) {
        print("Hit")
        balloon.removeFromParent()
        parachutingRatRight.removeFromParent()
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.parachutingRatRight != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Balloon != 0)) {
            projectileDidCollideWithparachutingRatRight(balloon: firstBody.node as! SKSpriteNode, parachutingRatRight: secondBody.node as! SKSpriteNode)
            score += 10
        }
        
    }
}



