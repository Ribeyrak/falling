//
//  GameScene.swift
//  falling
//
//  Created by Evhen Lukhtan on 01.11.2023.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    weak var gameDelegate: GameSceneDelegate?
    
    let ballCategory: UInt32 = 0x1 << 0
    let topBorderCategory: UInt32 = 0x1 << 1
    let borderCategory: UInt32 = 0x1 << 2
    
    var scroller: InfiniteScrollingBackground?
    let motionManager = CMMotionManager()
    
    // Textures
    var ballTexture: SKTexture!
    // Sprite Nodes
    var ball: SKSpriteNode!
    
    // Platform properties
    var platformSize: CGSize!
    var platforms: [SKShapeNode] = []
    
    var timer = 0
    var timerLabel: SKLabelNode!
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        ballTexture = SKTexture(imageNamed: "ball")
        platformSize = CGSize(width: self.size.width / 3, height: 20)
        motionManager.accelerometerUpdateInterval = 0.02
        motionManager.startAccelerometerUpdates()
        
        createGame()
    }
    
    func createGame() {
        createBG()
        createScreenBorders()
        createTopBorder()
        createBall()
        startGeneratingPlatforms(ofType: .red, withInterval: 1.5)
        startGeneratingPlatforms(ofType: .green, withInterval: 4.0)
        startTimer()
        setupTimer()
    }
    
    // MARK: - setup background
    func createBG() {
        let images = [
            UIImage(named: "bgImage1")!,
            UIImage(named: "bgImage2")!,
        ]
        scroller = InfiniteScrollingBackground(images: images,
                                               scene: self,
                                               scrollDirection: .top,
                                               transitionSpeed: 10)
        scroller?.scroll()
        scroller?.zPosition = -1
    }
    
    // MARK: - setup ball
    func createBall() {
        ball = SKSpriteNode(texture: ballTexture)
        ball.size = CGSize(width: 60, height: 60)
        ball.position = CGPoint(x: self.size.width / 2, y: self.size.height - 120)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.5)
        ball.physicsBody?.affectedByGravity = true
        ball.zPosition = 1
        ball.physicsBody?.categoryBitMask = ballCategory
        ball.physicsBody?.contactTestBitMask = topBorderCategory
        self.addChild(ball)
    }
    
    // MARK: - setup borders
    func createScreenBorders() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.categoryBitMask = borderCategory
    }
    
    func createTopBorder() {
        let topBorder = SKNode()
        let borderPosition = CGPoint(x: self.size.width / 2, y: self.size.height)
        let borderBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: 1), center: borderPosition)
        topBorder.physicsBody = borderBody
        topBorder.physicsBody?.categoryBitMask = topBorderCategory
        topBorder.physicsBody?.isDynamic = false
        self.addChild(topBorder)
    }
    
    // MARK: - setup platfroms
    func createPlatform(ofType type: PlatformType, at position: CGPoint) {
        let platform = SKShapeNode(rectOf: platformSize)
        
        switch type {
        case .red:
            platform.fillColor = .red
            platform.strokeColor = .red
        case .green:
            platform.fillColor = .green
            platform.strokeColor = .green
        }
        
        platform.position = position
        platform.zPosition = 0
        platform.physicsBody = SKPhysicsBody(rectangleOf: platformSize)
        platform.physicsBody?.isDynamic = false
        self.addChild(platform)
        platforms.append(platform)
        
        let moveUp = SKAction.moveBy(x: 0, y: self.size.height + platformSize.height, duration: 10)
        let remove = SKAction.removeFromParent()
        var actions: [SKAction] = [moveUp]
        
        if type == .green {
            let moveLeft = SKAction.moveBy(x: -self.size.width/2, y: 0, duration: 3)
            let moveRight = SKAction.moveBy(x: self.size.width/2, y: 0, duration: 3)
            let horizontalMovement = SKAction.sequence([moveLeft, moveRight])
            actions.append(SKAction.repeatForever(horizontalMovement))
        }
        
        platform.run(SKAction.sequence([SKAction.group(actions), remove])) { [weak self] in
            if let index = self?.platforms.firstIndex(of: platform) {
                self?.platforms.remove(at: index)
            }
        }
    }
    
    func startGeneratingPlatforms(ofType type: PlatformType, withInterval interval: TimeInterval) {
        let generatePlatform = SKAction.run { [weak self] in
            let x = CGFloat(arc4random_uniform(UInt32(self!.size.width)))
            let y: CGFloat = 0 - self!.platformSize.height / 2
            switch type {
            case .red:
                self?.createPlatform(ofType: .red, at: CGPoint(x: x, y: y))
            case .green:
                self?.createPlatform(ofType: .green, at: CGPoint(x: x, y: y))
            }
        }
        let delay = SKAction.wait(forDuration: interval)
        let sequence = SKAction.sequence([generatePlatform, delay])
        self.run(SKAction.repeatForever(sequence))
    }
    
    // MARK: - setup accelerometer
    func processAccelerometerData(_ data: CMAccelerometerData) {
        let acceleration = data.acceleration
        ball.physicsBody?.velocity = CGVector(dx: acceleration.x * 500, dy: 0)
    }
    
    // MARK: - flash animation
    func shakeAndFlashAnimation(view: SKView) {
        let aView = UIView(frame: view.frame)
        aView.backgroundColor = .white
        view.addSubview(aView)
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) {
            aView.alpha = 0.0
        } completion: { (done) in
            aView.removeFromSuperview()
        }
        
        //shake animation
        let shake = CAKeyframeAnimation(keyPath: "transform")
        shake.values = [
            NSValue(caTransform3D: CATransform3DMakeTranslation(-15, 5, 5)),
            NSValue(caTransform3D: CATransform3DMakeTranslation(15, 5, 5))
        ]
        shake.autoreverses = true
        shake.repeatCount = 2
        shake.duration = 7/100
        
        view.layer.add(shake, forKey: nil)
    }
    
    // MARK: - Timer
    func setupTimer() {
        timerLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timerLabel.text = "Time: \(timer) seconds"
        timerLabel.fontSize = 30
        timerLabel.fontColor = SKColor.white
        timerLabel.position = CGPoint(x: frame.size.width - timerLabel.calculateAccumulatedFrame().width + 35, y: frame.size.height - timerLabel.calculateAccumulatedFrame().height - 60)
        addChild(timerLabel)
    }
    
    func startTimer() {
        let wait = SKAction.wait(forDuration: 1) // Ждем 1 секунду
        let update = SKAction.run { [weak self] in
            self?.timer += 1
            self?.timerLabel.text = "Time: \(self?.timer ?? 0) seconds"
        }
        let sequence = SKAction.sequence([wait, update])
        self.run(SKAction.repeatForever(sequence), withKey: "timer")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelerometerData = motionManager.accelerometerData {
            processAccelerometerData(accelerometerData)
        }
    }
}

// MARK: - GameScene Contact Delegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == ballCategory | topBorderCategory {
            self.physicsWorld.speed = 0.0
            self.isPaused = true
            self.removeAllActions()
            self.removeAllChildren()
            shakeAndFlashAnimation(view: self.view!)
                        
            let isWinner = timer >= 30
            gameDelegate?.gameDidEnd(winner: isWinner)
        }
    }
}
