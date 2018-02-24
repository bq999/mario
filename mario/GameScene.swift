//
//  GameScene.swift
//  Mario
//
//  Created by Bilal Qaiser on 2018-01-29.
//  Copyright © 2018 Bilal Qaiser. All rights reserved.
//
import SpriteKit

class GameScene: SKScene {
    
    let mario2 = SKSpriteNode(imageNamed: "mario1")
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let marioAnimation: SKAction
    let jumpCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "jumpSound.wav", waitForCompletion: false)
    let loselifeCollisionSound: SKAction = SKAction.playSoundFileNamed(
        "loselifeSound.wav", waitForCompletion: false)

    var invincible = false
    var lives = 5
    var gameOver = false
    let cameraNode = SKCameraNode()
    let cameraMovePointsPerSec: CGFloat = 200.0
    let livesLabel = SKLabelNode(fontNamed: "Georgia-Italic")

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin,
                              width: size.width,
                              height: playableHeight)
        
        var textures:[SKTexture] = []
        // 2
        for i in 1...12 {
            textures.append(SKTexture(imageNamed: "mario\(i)"))
        }

        marioAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    override func didMove(to view: SKView) {
        
        playBackgroundMusic(filename: "BgSound.wav")

        
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPoint.zero
            background.position =
                CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
            background.zPosition = -1
            addChild(background)
        }
        

        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                },
                               SKAction.wait(forDuration: 3.0)])))
        
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.mario()
                },
                               SKAction.wait(forDuration: 300.0)])))

        
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width/2, y: size.height/2)
        livesLabel.text = "By: Bilal Qaiser  |  Lives: X"
        livesLabel.fontColor = SKColor.black
        livesLabel.fontSize = 100
        livesLabel.zPosition = 150
        livesLabel.horizontalAlignmentMode = .left
        livesLabel.verticalAlignmentMode = .top
        livesLabel.position = CGPoint(
            x: -playableRect.size.width/2 + CGFloat(20),
            y: playableRect.size.height/2 )
        cameraNode.addChild(livesLabel)
        

        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        moveCamera()
        

        
        livesLabel.text = "By: Bilal Qaiser  |  Lives: \(lives)"
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You lose!")
         
            
            // 1
            let gameOverScene = GameOverScene(size: size, won: false)
            gameOverScene.scaleMode = scaleMode
            // 2
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            // 3
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    
    func spawnEnemy() {
        
        let enemy = SKSpriteNode(imageNamed: "Enemy")
        enemy.position = CGPoint(
            x: cameraRect.maxX + enemy.size.width/2,
            y: 450)
        enemy.name = "enemy"
        addChild(enemy)
        
        let actionMove =
            SKAction.moveBy(x: -(size.width + enemy.size.width), y: 0, duration: 3.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    
    func mario() {
        
        let mario = SKSpriteNode(imageNamed: "mario1")
        mario.run(SKAction.repeatForever(marioAnimation))
        mario.name = "mario"
        
        mario.position = CGPoint(
            x: cameraRect.minX + 900,
            y: 450)
        
        addChild(mario)
        
        let actionMove =
            SKAction.moveBy(x: 60000, y: 0, duration: 300.0)
        let actionRemove = SKAction.removeFromParent()
        mario.run(SKAction.sequence([actionMove, actionRemove]))
        
    }
    
    
    func jump(){
        
        enumerateChildNodes(withName: "mario") { node, _ in
            let jump = node as! SKSpriteNode
            
            let animationDuration:TimeInterval = 0.8
            
            let up = SKAction.move(to: CGPoint(x: jump.position.x + 300, y: jump.position.y + 700), duration: animationDuration)
            
            let down = SKAction.move(to: CGPoint(x: jump.position.x + 350, y: jump.position.y ), duration: animationDuration)

            jump.run(SKAction.sequence([up, down]))
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        jump()
        run(jumpCollisionSound)

    }

    func marioHit(enemy: SKSpriteNode) {
        invincible = true
        enemy.name = "mario"
        
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime).truncatingRemainder(
                dividingBy: slice)
            node.isHidden = remainder > slice / 2
        }
        
        
        let setHidden = SKAction.run() { [weak self] in
            enemy.isHidden = false
            self?.invincible = false
        }
        enemy.run(SKAction.sequence([blinkAction, setHidden]))
        
        run(loselifeCollisionSound)
        lives -= 1
        
    }
    
    
    func checkCollisions() {
        
        if invincible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "mario") { node, _ in
            let mario = node as! SKSpriteNode
            
            self.enumerateChildNodes(withName: "enemy") { node, _ in
                let enemy = node as! SKSpriteNode
                
                if enemy.frame.intersects(mario.frame) {
                    hitEnemies.append(mario)
                }
            }
        }
        for enemy in hitEnemies {
            marioHit(enemy: enemy)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func backgroundNode() -> SKSpriteNode {
        // 1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        // 2
        let background1 = SKSpriteNode(imageNamed: "bakground")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 150, y: 150)
        backgroundNode.addChild(background1)
        
        // 3
        let background2 = SKSpriteNode(imageNamed: "bakground")
        background2.anchorPoint = CGPoint.zero
        background2.position =
            CGPoint(x: background1.size.width, y: 150)
        backgroundNode.addChild(background2)
        
        // 4
        backgroundNode.size = CGSize(
            width: background1.size.width + background2.size.width,
            height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity =
            CGPoint(x: cameraMovePointsPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodes(withName: "background") { node, _ in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width <
                self.cameraRect.origin.x {
                background.position = CGPoint(
                    x: background.position.x + background.size.width*2,
                    y: background.position.y)
            }
        }
    }
    
    var cameraRect : CGRect {
        let x = cameraNode.position.x - size.width/2
            + (size.width - playableRect.width)/2
        let y = cameraNode.position.y - size.height/2
            + (size.height - playableRect.height)/2
        return CGRect(
            x: x,
            y: y,
            width: playableRect.width,
            height: playableRect.height)
    }
    
}
