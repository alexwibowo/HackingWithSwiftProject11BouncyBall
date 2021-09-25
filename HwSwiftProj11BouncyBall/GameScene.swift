//
//  GameScene.swift
//  HwSwiftProj11BouncyBall
//
//  Created by Alex Wibowo on 24/9/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel : SKLabelNode!
    
    var editLabel : SKLabelNode!
   
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isEditing = false
    
    override func didMove(to view: SKView) {
        let backgroundSprite = SKSpriteNode(imageNamed: "background")
        backgroundSprite.position = CGPoint(x: 512, y: 384)
        backgroundSprite.blendMode = .replace
        backgroundSprite.zPosition = -1
        addChild(backgroundSprite)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.horizontalAlignmentMode = .left
        editLabel.position = CGPoint(x: 10, y: 700)
        editLabel.name = "editButton"
        addChild(editLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        
        makeSlot(at: CGPoint(x:128, y:0), isGood: true)
        makeSlot(at: CGPoint(x:384, y:0), isGood: false)
        makeSlot(at: CGPoint(x:640, y:0), isGood: true)
        makeSlot(at: CGPoint(x:896, y:0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        let slotSprite: SKSpriteNode
        let glowSprite: SKSpriteNode
        if isGood {
            slotSprite = SKSpriteNode(imageNamed: "slotBaseGood")
            glowSprite = SKSpriteNode(imageNamed: "slotGlowGood")
            slotSprite.name = "good"
        } else {
            slotSprite = SKSpriteNode(imageNamed: "slotBaseBad")
            slotSprite.name = "bad"
            glowSprite = SKSpriteNode(imageNamed: "slotGlowBad")
        }
        slotSprite.position = position
        slotSprite.physicsBody = SKPhysicsBody(rectangleOf: slotSprite.size)
        slotSprite.physicsBody?.isDynamic = false
        glowSprite.position = position
        
        glowSprite.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 2)))
        
        addChild(glowSprite)
        addChild(slotSprite)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        
        let nodes = nodes(at: touchLocation)
        if nodes.contains(editLabel) {
            
            isEditing.toggle()
            if isEditing {
                editLabel.text = "Done"
                
            } else {
                editLabel.text = "Edit"
            }
            
            
        } else {
            
            if isEditing {
                let size = CGSize(width: Int.random(in: 50...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1),
                                            green: CGFloat.random(in: 0...1),
                                            blue: CGFloat.random(in: 0...1),
                                            alpha: 1), size: size)
                
                box.physicsBody = SKPhysicsBody(rectangleOf: size)
                
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = touchLocation
                box.physicsBody?.isDynamic = false
                addChild(box)
                
            } else {
               
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
                ball.position = touchLocation
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.name = "ball"
                
                addChild(ball)
            }
          
        }
 
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(ball: nodeA, other: nodeB)
        } else if nodeB.name == "ball" {
            collision(ball: nodeB, other: nodeA)
        }
    }
    
    func collision(ball: SKNode, other: SKNode){
        if other.name == "good" {
            score += 1
            
            destroyBall(ball: ball)
        } else if other.name == "bad" {
            score -= 1
            destroyBall(ball: ball)
        }
    }
    
    func destroyBall(ball: SKNode){
        if let particle = SKEmitterNode(fileNamed: "FireParticles.sks") {
            particle.position = ball.position
            addChild(particle)
        }
        ball.removeFromParent()
    }
    
    
   
}

