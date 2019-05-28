//
//  GameScene.swift
//  Sapce Shooter
//
//  Created by Seth VanBrocklin on 4/1/19.
//  Copyright © 2019 Seth VanBrocklin. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCatagory {
    static let Enemy : UInt32 = 1
    static let Bullet : UInt32 = 2
    static let Player : UInt32 = 3
    static let Bottom : UInt32 = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var FnemyTimer: Timer? = nil
    var EnemyTimer: Timer? = nil
    var BulletTimer: Timer? = nil
    var gameLogo: SKLabelNode!
    var gameLogo2: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    var Score = Int()
    var Player = SKSpriteNode( imageNamed: "Player.png")
    var ScoreLabel = UILabel()
    var BackgroundView = SKSpriteNode(imageNamed: "background.png")
    var Game = true
    var Life1 = SKSpriteNode(imageNamed: "Heart.png")
    var Life2 = SKSpriteNode(imageNamed: "Heart.png")
    var Life3 = SKSpriteNode(imageNamed: "Heart.png")
    var Bottom = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        initializeMenu()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Bullet) || (firstBody.categoryBitMask == PhysicsCatagory.Bullet) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy)){
            CollisionWithBullet(Enemy: firstBody.node as! SKSpriteNode, Bullet: secondBody.node as! SKSpriteNode)
        }
        else if((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Player)){
            Game = false
        }
        else if((firstBody.categoryBitMask == PhysicsCatagory.Player) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy)){
            Game = false
        }
        else if((firstBody.categoryBitMask == PhysicsCatagory.Enemy) && (secondBody.categoryBitMask == PhysicsCatagory.Bottom)){
            CollisionWithBottom(Enemy: firstBody.node as! SKSpriteNode)
        }
        else if((firstBody.categoryBitMask == PhysicsCatagory.Bottom) && (secondBody.categoryBitMask == PhysicsCatagory.Enemy)){
            CollisionWithBottom(Enemy: secondBody.node as! SKSpriteNode)
        }
    }
    
    func CollisionWithBullet(Enemy: SKSpriteNode, Bullet:SKSpriteNode){
        Enemy.removeFromParent()
        Bullet.removeFromParent()
        Score+=1
        
        ScoreLabel.text = "\(Score)"
    }
    
    func CollisionWithBottom(Enemy: SKSpriteNode){
        Enemy.removeFromParent()
        if(Life1.isHidden == false){
            Life1.isHidden = true
        }
        else if(Life2.isHidden == false){
            Life2.isHidden = true
        }
        else if(Life3.isHidden == false){
            Life3.isHidden = true
            Game = false
        }
    }
    
    @objc func SpawnBullets(){
        let Bullet = SKSpriteNode( imageNamed: "Bullet.png")
        Bullet.position = CGPoint(x:Player.position.x, y: Player.position.y)
        Bullet.zPosition = -5
        
        let action = SKAction.moveTo(y: ((frame.size.height/2) + 20) , duration: 1.4)
        let actionDone = SKAction.removeFromParent()
        Bullet.run(SKAction.sequence([action, actionDone]))
        
        Bullet.physicsBody = SKPhysicsBody(rectangleOf: Bullet.size)
        Bullet.physicsBody?.categoryBitMask = PhysicsCatagory.Bullet
        Bullet.physicsBody?.affectedByGravity = false
        Bullet.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        Bullet.physicsBody?.isDynamic = false
        
        self.addChild(Bullet)
    }
    
    @objc func SpawnEnemies(){
        let Enemy = SKSpriteNode(imageNamed: "Player (1).png")
        let MinValue = frame.size.width/8
        let MaxValue = ((frame.size.width/2)-20)
        let SpawnPoint = UInt32(MaxValue-MinValue)
        Enemy.position = CGPoint(x:CGFloat(arc4random_uniform(SpawnPoint*2)), y: 680)
        Enemy.position.x = Enemy.position.x - 261
        Enemy.zPosition = 0
        
        Enemy.physicsBody = SKPhysicsBody(rectangleOf: Enemy.size)
        Enemy.physicsBody?.categoryBitMask = PhysicsCatagory.Enemy
        Enemy.physicsBody?.affectedByGravity = false
        Enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Bullet
        Enemy.physicsBody?.isDynamic = true
        
        let action = SKAction.moveTo(y: (frame.size.height/(-2)-40), duration: 2.0)
        let actionDone = SKAction.removeFromParent()
        Enemy.run(SKAction.sequence([action, actionDone]))
        
        self.addChild(Enemy)
    }
    
    @objc func SpawnFakeEnemies(){
        let Fnemy = SKSpriteNode(imageNamed: "Player (1).png")
        let MinValue = frame.size.width/8
        let MaxValue = ((frame.size.width/2)-20)
        let SpawnPoint = UInt32(MaxValue-MinValue)
        Fnemy.position = CGPoint(x:CGFloat(arc4random_uniform(SpawnPoint*2)), y: 680)
        Fnemy.position.x = Fnemy.position.x - 261
        Fnemy.zPosition = 0
        
        let action = SKAction.moveTo(y: (frame.size.height/(-2)-40), duration: 2.0)
        let actionDone = SKAction.removeFromParent()
        Fnemy.run(SKAction.sequence([action, actionDone]))
        
        self.addChild(Fnemy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            Player.position.x = t.location(in: self).x
            let location = t.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if node.name == "play_button" {
                    startGame()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {Player.position.x = t.location(in: self).x
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(Game==false){
            Game=true
            print("game end")
            if(EnemyTimer != nil){
                EnemyTimer!.invalidate()
                EnemyTimer = nil
            }
            if(BulletTimer != nil){
                BulletTimer!.invalidate()
                BulletTimer = nil
            }
            self.Player.removeFromParent()
            self.Life1.removeFromParent()
            self.Life2.removeFromParent()
            self.Life3.removeFromParent()
            self.Bottom.removeFromParent()
            self.ScoreLabel.isHidden = true
            
            gameLogo.isHidden = false
            gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (frame.size.height / 2) - 200), duration: 0.5)) {
                self.gameLogo2.isHidden = false
                self.gameLogo2.run(SKAction.move(to: CGPoint(x: 0, y: (self.frame.size.height / 2) - 300), duration: 0.5))
                self.playButton.isHidden = false
                self.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                if self.Score > UserDefaults.standard.integer(forKey: "bestScore") {
                    UserDefaults.standard.set(self.Score, forKey: "bestScore")
                }
                self.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
                self.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.gameLogo.position.y - 150), duration: 0.3))
            }
            FnemyTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(SpawnFakeEnemies), userInfo: nil, repeats: true)
        }
    }
    
    private func initializeMenu() {
        FnemyTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(SpawnFakeEnemies), userInfo: nil, repeats: true)
        BackgroundView.size.width = frame.size.width
        BackgroundView.size.height = frame.size.height
        BackgroundView.zPosition = -20
        self.addChild(BackgroundView)
        //Create game title
        gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
        gameLogo.fontSize = 100
        gameLogo.text = "SPACE"
        gameLogo.fontColor = SKColor.red
        self.addChild(gameLogo)
        gameLogo2 = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo2.zPosition = 1
        gameLogo2.position = CGPoint(x: 0, y: (frame.size.height / 2) - 300)
        gameLogo2.fontSize = 100
        gameLogo2.text = "SHOOTER"
        gameLogo2.fontColor = SKColor.red
        self.addChild(gameLogo2)
        //Create best score label
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 150)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        UserDefaults.standard.set(0, forKey: "bestScore")
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
        //Create play button
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition = 1
        playButton.position = CGPoint(x: 0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.red
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
    }
    
    private func initializeGame() {
        physicsWorld.contactDelegate = self
        
        Bottom.size.width = frame.size.width
        Bottom.size.height = 10
        Bottom.position.y = (frame.size.height / -2)
        Bottom.zPosition = -50
        Bottom.physicsBody = SKPhysicsBody(rectangleOf: Bottom.size)
        Bottom.physicsBody?.affectedByGravity = false
        Bottom.physicsBody?.categoryBitMask = PhysicsCatagory.Bottom
        Bottom.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        Bottom.physicsBody?.isDynamic = false
        Bottom.color = SKColor.blue
        self.addChild(Bottom)
        
        Life1.isHidden = false
        Life1.size.width = 60
        Life1.size.height = 60
        Life1.zPosition = 10
        Life1.position.x = ((frame.size.width/10)+30)
        Life1.position.y = ((frame.size.height/2)-80)
        self.addChild(Life1)
        
        Life2.isHidden = false
        Life2.size.width = 60
        Life2.size.height = 60
        Life2.position.x = (2*(frame.size.width/10)+30)
        Life2.position.y = ((frame.size.height/2)-80)
        self.addChild(Life2)
        
        Life3.isHidden = false
        Life3.size.width = 60
        Life3.size.height = 60
        Life3.position.x = (3*(frame.size.width/10)+30)
        Life3.position.y = ((frame.size.height/2)-80)
        self.addChild(Life3)
        
        Player.position.x = 0
        Player.position.y = (frame.size.height / -3)
        Player.zPosition = 10
        Player.physicsBody = SKPhysicsBody(rectangleOf: Player.size)
        Player.physicsBody?.affectedByGravity = false
        Player.physicsBody?.categoryBitMask = PhysicsCatagory.Player
        Player.physicsBody?.contactTestBitMask = PhysicsCatagory.Enemy
        Player.physicsBody?.isDynamic = false
        self.addChild(Player)
        
        Score = 0
        ScoreLabel.text = "\(Score)"
        ScoreLabel =  UILabel(frame: CGRect(x: 20, y: 20, width: 60, height: 50))
        ScoreLabel.textColor = UIColor.white
        ScoreLabel.font = ScoreLabel.font.withSize(30)
        ScoreLabel.textAlignment = NSTextAlignment.center
        self.view?.addSubview(ScoreLabel)
    }
    
    private func startGame() {
        print("start game")
        
        if(FnemyTimer != nil){
            FnemyTimer!.invalidate()
            FnemyTimer = nil
        }
        
        gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameLogo.isHidden = true
        }
        
        gameLogo2.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
            self.gameLogo2.isHidden = true
        }
        
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        
        let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
        bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4)){
            self.initializeGame()
            self.BulletTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.SpawnBullets), userInfo: nil, repeats: true)
            self.EnemyTimer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.SpawnEnemies), userInfo: nil, repeats: true)
        }
    }
}
