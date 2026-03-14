//
//  GameOverScene.swift
//  Banksy's Balloon Girl
//
//  Created by Roger Westfall on 11/26/16.
//  Copyright © 2016 Roger Westfall. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    //scoreLabel
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // backgroundColor = SKColor.lightGray
        let background = SKSpriteNode(imageNamed: "backgroundHills")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0 //backmost layer
        self.addChild(background)
        
        // 2
        let message = won ? "You Won!" : "Rats! " +
        "Game Over"
        
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 30
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        label.zPosition = 2
        addChild(label)
        
        // 4
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                // 5
                let reveal = SKTransition.fade(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 5.0, y: 625)
        scoreLabel.zPosition = 3
        addChild(scoreLabel)
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
