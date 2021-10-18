//
//  GameScene.swift
//  FlappyClone
//
//  Created by Ian Cowan on 12/4/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var scoreLabel : SKLabelNode = SKLabelNode()
    private var labelBack : SKShapeNode = SKShapeNode()
    
    private var ground: SKSpriteNode = SKSpriteNode()
    private var ghost: SKSpriteNode = SKSpriteNode()
    private var wallPair: SKNode = SKNode()
    private var moveAndRemove: SKAction = SKAction()
    private var gameStarted: Bool = false
    private var score: Int = 0
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        scoreLabel.position = CGPoint(x: 0, y: self.frame.maxY / 1.5)
        scoreLabel.fontColor = SKColor.black
        scoreLabel.zPosition = 5
        
        self.updateLabel()
        
        labelBack.fillColor = SKColor.gray
        labelBack.zPosition = 4
        
        ground = SKSpriteNode(imageNamed: "Ground")
        ground.setScale(0.5)
        ground.position = CGPoint(x: 0, y: self.frame.minY + ground.frame.height / 2)
        ground.zPosition = 3
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        
        ghost = SKSpriteNode(imageNamed: "Ghost")
        ghost.size = CGSize(width: 60, height: 70)
        ghost.position = CGPoint(x: -ghost.frame.width, y: 0)
        ghost.zPosition = 2
        ghost.physicsBody = SKPhysicsBody(circleOfRadius: ghost.frame.height / 2)
        ghost.physicsBody?.categoryBitMask = PhysicsCategory.ghost
        ghost.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.wall
        ghost.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.wall | PhysicsCategory.score
        ghost.physicsBody?.affectedByGravity = false
        ghost.physicsBody?.isDynamic = true
        
        self.addChild(scoreLabel)
        self.addChild(labelBack)
        self.addChild(ghost)
        self.addChild(ground)
    }
    
    func createWalls() {
        wallPair = SKNode()
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.maxX + topWall.frame.width / 2, y: 350)
        topWall.zRotation = CGFloat(Double.pi)
        bottomWall.position = CGPoint(x: self.frame.maxX + bottomWall.frame.width / 2, y: -350)
        
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.isDynamic = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.ghost
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        bottomWall.physicsBody?.affectedByGravity = false
        bottomWall.physicsBody?.isDynamic = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1, height: 200)
        scoreNode.position = CGPoint(x: self.frame.maxX + topWall.frame.width, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.ghost
        
        wallPair.zPosition = 1
        
        let randomPosition = Random().getNextCGFloat(min: -150, max: 150)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.run(moveAndRemove)
        wallPair.addChild(scoreNode)
        self.addChild(wallPair)
    }
    
    func updateLabel() {
        scoreLabel.text = "\(score)"
        
        labelBack.path = UIBezierPath(roundedRect: CGRect(x: scoreLabel.frame.midX - scoreLabel.frame.width * 0.75, y: scoreLabel.frame.midY - scoreLabel.frame.height * 0.75, width: scoreLabel.frame.width * 1.5, height: scoreLabel.frame.height * 1.5), cornerRadius: 20).cgPath
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            let spawn = SKAction.run({ () in
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let spawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(spawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat((self.frame.width + wallPair.frame.width) * 1.5)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: ghost.frame.height * 1.3))
            ghost.physicsBody?.affectedByGravity = true
            
            gameStarted = true
        } else {
            ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
            ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: ghost.frame.height * 1.3))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.score && secondBody.categoryBitMask == PhysicsCategory.ghost || secondBody.categoryBitMask == PhysicsCategory.score && firstBody.categoryBitMask == PhysicsCategory.ghost {
            score += 1
            self.updateLabel()
        }
    }
}

struct PhysicsCategory {
    static let ghost: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
    static let wall: UInt32 = 0x1 << 3
    static let score: UInt32 = 0x1 << 4
}

struct Random {
    func getNextCGFloat() -> CGFloat {
        return CGFloat(Float(arc4random())) / 0xFFFFFFFF
    }
    
    func getNextCGFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return getNextCGFloat() * (max - min) + min
    }
}
