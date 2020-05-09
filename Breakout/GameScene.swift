//
//  GameScene.swift
//  Breakout
//
//  Created by Brandon Escobar on 3/9/20.
//  Copyright © 2020 Brandon Escobar. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var brick = SKSpriteNode()
    var bricks = [SKSpriteNode()]
    var loseZone = SKSpriteNode()
    var playLabel = SKLabelNode()
    var brickRemoved = 0
    var gameOn = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        makeLoseZone()
        makeLabels()
        renew()
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "Stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makeLabels() {
        playLabel.fontSize = 36
        playLabel.text = "Tap to start"
        playLabel.fontName = "Ariel"
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLabel.name = "play"
        addChild(playLabel)
    }
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = .black
        ball.fillColor = .yellow
        ball.name = "Ball"
        
        // physic shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball)// add ball object to the view
    }
    
    func makeLabel() {
        playLabel.fontSize = 36
        playLabel.text = "Tap to start"
        playLabel.fontName = "Arial"
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLabel.name = "play"
        addChild(playLabel)
    }
    
    func makePaddle() {
        //paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width/4, height: 20))
        paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "Paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBricks() {
        for brick in bricks {
            if brick.parent != nil {
                brick.removeFromParent()
            }
        }
        bricks.removeAll()
        brickRemoved = 0
        let wideCount = Int(frame.width) / 55
        for x in 0..<wideCount{
            makeBrick(X: x, Y: 40, color: .blue)
        }
        for x in 0..<wideCount{
            makeBrick(X: x, Y: 65, color: .green)
        }
        for x in 0..<wideCount{
            makeBrick(X: x, Y: 90, color: .yellow)
        }
        for x in 0..<wideCount{
            makeBrick(X: x, Y: 115, color: .red)
        }
    }
    
    func makeBrick(X: Int, Y: Int, color: UIColor) {
        let count = Int(frame.width) / 55
        let xOffset = (Int(frame.width) - (count * 55)) / 2 + Int(frame.minX) + 25
        brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.name = "Brick"
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        brick.position = CGPoint(x: X * 55 + xOffset, y: Int(frame.maxY) - Y)
        addChild(brick)
        bricks.append(brick)
    }
    
    func makeLoseZone(){
        loseZone = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    func renew() {
        ball.removeFromParent()
        makeBall()
        paddle.removeFromParent()
        makePaddle()
        makeBricks()
        brickRemoved = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if gameOn {
                paddle.position.x = location.x
            } else {
                for node in nodes(at: location) {
                    if node.name == "play" {
                        gameOn = true
                        node.alpha = 0
                        kickBall()
                    }
                }
            }
            paddle.position.x = location.x
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if gameOn {
                paddle.position.x = location.x
            }
        }
    }
    
    func kickBall() {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: 5, dy: 5))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        for brick in bricks{
            if contact.bodyA.node == brick ||
                contact.bodyB.node == brick {
                if brick.color == UIColor.blue {
                    brick.color = UIColor.green
                } else if brick.color == UIColor.green {
                    brick.color = UIColor.yellow
                } else if brick.color == UIColor.yellow {
                    brick.color = UIColor.red
                } else if brick.color == UIColor.red {
                    brick.removeFromParent()
                    brickRemoved += 1
                    if brickRemoved == bricks.count {
                        gameOver(win: true)
                    }
                }
            }
            /*
            if contact.bodyA.node?.name == "Paddle" ||
                contact.bodyB.node?.name == "Paddle" {
                ball.physicsBody?.applyImpulse(CGVector(dx: 0.005, dy: 0.005))
            }
             */
            if contact.bodyA.node?.name == "loseZone" ||
                contact.bodyB.node?.name == "loseZone" {
                gameOver(win: false)
            }
        }
    }
    
    func gameOver(win: Bool){
        playLabel.fontSize = 25
        gameOn = false
        playLabel.alpha = 1
        renew()
        if (win){
            playLabel.text = "Winner! Tap to play again"
        }
        else{
            playLabel.text = "GAME OVER! Tap to play again"
        }
    }
}
