//
//  GameScene.swift
//  StarWarsBeta
//
//  Created by Aidyn Mukhametzhanov on 1/1/19.
//  Copyright © 2019 Aidyn Mukhametzhanov. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ColliderType : UInt32{
    
    case SPMan = 1, SPAst
}

enum PhysicsType : UInt32{
    
    case Asteroid = 1, Bullet = 2, None = 3, SpaceMan = 10
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /*
    let joystick = Joystick()
    //let player = SKSpriteNode(color: UIColor.red, size: CGSize(width: 20, height: 20))
    var player  = SKSpriteNode.init(imageNamed: "Saturn.png")
    
    override func didMove(to view: SKView) {
        joystick.position = CGPoint(x:-60, y:-220)
        addChild(joystick)
        addChild(player)
        
        //player = SKSpriteNode.init(imageNamed: "saturn.png")
        player.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        player.physicsBody?.mass = 1
        player.physicsBody?.allowsRotation = false
        player.position = CGPoint(x: 0, y: 0)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsWorld.gravity = CGVector(dx:0, dy:0)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.moveJoystick(touch: touches.first!)
        
        joystick.joystickAction = { (x:CGFloat, y:CGFloat) in
            self.player.physicsBody?.applyForce(CGVector(dx: x * 70, dy: y * 70))
        }
    }
    
    */
    
 
    var bkgNode: SKNode!
    
    var bgTexture: SKTexture!
    var bgObject=SKNode()
    var bg=SKSpriteNode()
    var spMan=SKSpriteNode()
    var spAst=SKSpriteNode()
    var bodySp=SKPhysicsBody(rectangleOf: CGSize(width: 106, height: 86))
    var bodyAst=SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 112))
    
    
    var bg2 = SKSpriteNode()
    var bg3 = SKSpriteNode()
    var sz: CGFloat = 300

    
    var parallax = SKAction()
    
    var coin = SKSpriteNode()
    var lb = SKLabelNode()
    var ground = SKSpriteNode()
    var boss = SKSpriteNode()
    var coinCount: Int = 0
    var isCrushed: Bool = false
    var coinTotal: Int = 3
    
    override func update(_ currentTime: TimeInterval) {
        moveGrounds()
    }
    
    
    func createGrounds()
    {
        for i in 0...3{
            let ground = SKSpriteNode(imageNamed: "bkg.png")
            ground.name="Ground"
            ground.size=CGSize(width: self.size.width, height: self.size.height)
            ground.position=CGPoint(x: 0, y: CGFloat(i)*ground.size.height)
            ground.anchorPoint=CGPoint(x: 0.5, y: 0.5)
            self.addChild(ground)
        }
    }
    
    func moveGrounds(){
        self.enumerateChildNodes(withName: "Ground", using:
            ({
                (node,error) in
                    //print(node.position.y)
                    node.position.y-=10
                    if node.position.y < -((self.scene?.size.height)!)
                    {
                        //print(node.position.y)
                        node.position.y += (self.scene?.size.height)! * 3
                    }
            }))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
                //spMan.position.x = touch.location(in: self).x
                //spMan.position.y = touch.location(in: self).y
        }
        
        if(coinTotal==coinCount)
        {
            let t = touches.first
            spMan.position.x = t?.location(in: self).x ??  0
            spMan.position.y = t?.location(in: self).y ??  0
            
            print("\(coinCount) and \(coinTotal)")
            
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(ShootShuriken),
                    SKAction.wait(forDuration: 3.0)
                    ])
            ))
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    
    func addAsteroid() {
        
        let asteroid = SKSpriteNode(imageNamed: "Flare asteroid.png")
        asteroid.size=CGSize(width: 40, height: 40)
        asteroid.zPosition=3
        asteroid.name="Asteroid"
        
        
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: asteroid.size)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = PhysicsType.Asteroid.rawValue
        asteroid.physicsBody?.contactTestBitMask = PhysicsType.SpaceMan.rawValue
        //asteroid.physicsBody?.collisionBitMask = PhysicsType.None.rawValue//
        asteroid.physicsBody?.affectedByGravity=false
        
 
        let xw: CGFloat = self.size.width/2
        let yh: CGFloat = self.size.height/2
        asteroid.position = CGPoint(x: CGFloat.random(in: -xw+asteroid.size.width...xw-asteroid.size.width), y: -yh)

        if(!isCrushed){
            if(coinCount<coinTotal){
            
                addChild(asteroid)
            
                let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
                let actionMove = SKAction.move(to: CGPoint(x: asteroid.position.x, y: asteroid.position.y + yh*2 + asteroid.size.height), duration: TimeInterval(actualDuration))
                asteroid.run(actionMove)
            }
            else
            {
                createBoss()
            }
        }
        
    }
    
    func createBoss()
    {
        let boss = SKSpriteNode(imageNamed: "Boss.png")
        let b = self.childNode(withName: "Boss")
        if b == nil{
            //boss.size=CGSize(width: self.size.width, height: 40)
            boss.position = CGPoint(x: 0, y: -self.size.height/2+boss.size.height/6)
            boss.zPosition=3
            boss.name="Boss"
            self.addChild(boss)
        }
    }
    
    func createCoin()
    {
        coin = SKSpriteNode(imageNamed: "coin.png")
        let b = self.childNode(withName: "Coin")
        if b == nil{
            coin.size=CGSize(width:20, height: 20)
            coin.position = CGPoint(x: self.size.width/2-3*coin.size.width, y: self.size.height/2-coin.size.height)
            coin.zPosition=3
            coin.name="Coin"
            self.addChild(coin)
        }
    }
    
    func createCoinLabel()
    {
        var lb = SKLabelNode()
        let b = self.childNode(withName: "CoinLabel")
        if b == nil{
            
            lb.name="CoinLabel"
            lb.position = CGPoint(x: self.size.width/2-3*coin.size.width, y: coin.position.y-coin.size.height)
            lb.color=UIColor.yellow
            lb.fontSize=10
            lb.zPosition=3
            lb.text = "\(coinCount)"
            self.addChild(lb)
        }
        else{
            lb = b as! SKLabelNode
            lb.text = "\(coinCount)"
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        didCollide(body1: contact.bodyA.node as! SKSpriteNode, body2: contact.bodyB.node as! SKSpriteNode)
    }
    
    func didCollide(body1: SKSpriteNode, body2: SKSpriteNode)
    {
        
        if(body1.name=="Bullet" && body2.name=="Asteroid") || (body1.name=="Asteroid" && body2.name=="Bullet")
        {
            coinCount+=1
            body1.removeFromParent()
            body2.removeFromParent()
            
            createCoinLabel()
           
        }
        if(body1.name=="Crusher" && body2.name=="Asteroid") || (body1.name=="Asteroid" && body2.name=="Crusher")
        {
            let lb = SKSpriteNode(imageNamed: "boom")
            lb.size=CGSize(width: 120, height: 120)
            lb.zPosition=3
            body1.removeFromParent()
            body2.removeFromParent()
            self.addChild(lb)
            
            isCrushed = true
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        
        if isCrushed {return}
        
        let touchLocation = touch.location(in: self)
        
        let bullet = SKSpriteNode(imageNamed: "Shuriken")
        bullet.zPosition=3
        bullet.name="Bullet"
        bullet.size=CGSize(width: 20, height: 20)
        bullet.position.y = spMan.position.y-bullet.size.height
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        //bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsType.Bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = PhysicsType.Asteroid.rawValue
        bullet.physicsBody?.collisionBitMask = PhysicsType.None.rawValue
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.allowsRotation=false
        
        let offset = touchLocation - bullet.position
        //if offset.x < 0 { return }
        
        if(coinTotal>coinCount){
            addChild(bullet)
            let direction = offset.normalized()
            let shootAmount = direction * 1000
            let realDest = shootAmount + bullet.position
            
            let actionMove = SKAction.move(to: realDest, duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
        
    }
    
    func ShootShuriken ()
    {
        let bullet = SKSpriteNode(imageNamed: "Shuriken")
        bullet.zPosition=3
        bullet.name="Bullet"
        bullet.size=CGSize(width: 20, height: 20)
        bullet.position.y = boss.position.y+bullet.size.height
        bullet.position.x = boss.position.x
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        //bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsType.Bullet.rawValue
        bullet.physicsBody?.contactTestBitMask = PhysicsType.Asteroid.rawValue
        bullet.physicsBody?.collisionBitMask = PhysicsType.None.rawValue
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.allowsRotation=false
        
        print("spManX=\(spMan.position.x) and spManY=\(spMan.position.y)")
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        print("actualDuration= \(actualDuration)")
        print("bossX=\(boss.position.x) and bossY=\(boss.position.y)")
        let actionMove = SKAction.move(to: spMan.position, duration: TimeInterval(actualDuration))
        bullet.run(actionMove)
        
    }
    
    func addEmitter()
    {
        let emitter = SKEmitterNode(fileNamed: "RainParticle")!
        emitter.zPosition=2
        emitter.position=CGPoint(x: size.width/2, y: size.height)
        addChild(emitter)
    }
    
    override func didMove(to view: SKView) {
        
        createGrounds()
        createCoin()
        createCoinLabel()
        
        addEmitter()
        
        
        spMan = SKSpriteNode.init(imageNamed: "spaceman.png")
        spMan.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 80, height: 60))
        spMan.physicsBody?.categoryBitMask = PhysicsType.SpaceMan.rawValue
        spMan.physicsBody?.contactTestBitMask = PhysicsType.Asteroid.rawValue
        //spMan.physicsBody?.collisionBitMask = PhysicsType.None.rawValue
        spMan.physicsBody?.affectedByGravity=false
        spMan.name="Crusher"
        
        spMan.zPosition=3
        spMan.size=CGSize(width: 80, height: 80)
        spMan.position=CGPoint(x: 0, y: 150)
        self.addChild(spMan)
        
       
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(addAsteroid),
                    SKAction.wait(forDuration: 3.0)
                    ])
            ))
      
        
        //self.anchorPoint=CGPoint(x: 0.5, y: 0.5)
        
        /*
        sz = self.frame.size.height/3
        
        bg = SKSpriteNode(imageNamed: "bkg.png")
        bg.zPosition = 3
        bg.size = CGSize(width:self.frame.size.width, height:sz)
        var diff = self.frame.size.height/2 - bg.size.height/2
        bg.position = CGPoint(x: 0, y: -diff)
        
        bg2 = SKSpriteNode(imageNamed: "bkg.png")
        bg2.zPosition = 3
        bg2.size = CGSize(width:self.frame.size.width, height:sz)
        diff = bg.position.y + bg2.size.height
        bg2.position = CGPoint(x: 0, y:diff)
        
        bg3 = SKSpriteNode(imageNamed: "background.png")
        bg3.zPosition = 3
        bg3.size = CGSize(width:self.frame.size.width, height:sz)
        diff = bg2.position.y+bg3.size.height
        bg3.position = CGPoint(x: 0, y:diff)
        
        self.addChild(bg)
        self.addChild(bg2)
        self.addChild(bg3)
        
        parallax = SKAction.repeatForever(SKAction.move(by: CGVector(dx: 0, dy: -self.frame.size.height/2), duration: 7))
        //higher duration moves it slower, lower duration moves it faster
  
        
        
        bg.run(parallax)
        bg2.run(parallax)
        bg3.run(parallax)
        
        */
        
        
        
        //self.addChild(bgObject)
        physicsWorld.contactDelegate = self
        
        
        
        /*
        createActor()
        
        let dt = DispatchTime.now() + .seconds(2)
        DispatchQueue.main.asyncAfter(deadline: dt){
            self.createAsteroid()
            let mvAst = SKAction.move(by: CGVector(dx: 0, dy: 200), duration: 2)
            self.spAst.run(mvAst)
        }
        */
        
        //let mvSp = SKAction.move(by: CGVector(dx: 0, dy: -self.size.height+spMan.size.height), duration: 10)
        //spMan.run(mvSp)
    }
    
    
    /*
    
    func createBg(){
        bgTexture=SKTexture(imageNamed: "bkg.png")
        let moveBg=SKAction.moveBy(x: 0, y: -bgTexture.size().height, duration: 3)
        let replaceBg=SKAction.moveBy(x: 0, y: bgTexture.size().height, duration: 3)
        let moveBgForever=SKAction.repeatForever(SKAction.sequence([moveBg,replaceBg]))
        
        for i in 0..<3{
            bg=SKSpriteNode(texture: bgTexture)
            bg.position=CGPoint(x:0, y:  bg.size.height * CGFloat(i))
            bg.size.height = self.frame.height
            bg.size.width=self.frame.width
            bg.run(moveBgForever)
            bg.zPosition = -1
            bgObject.addChild(bg)
        }
        
    }
    
    
    
    func createGrounds()
    {
        for i in 0...3{
            let ground = SKSpriteNode(imageNamed: "Saturn.png")
            ground.name="Ground"
            ground.size=CGSize(width: (self.scene?.size.width)!, height: 250)
            ground.anchorPoint=CGPoint(x:CGFloat(i) * ground.size.width,y:-(self.frame.size.height / 2))
            self.addChild(ground)
        }
    }
    
    func moveGrounds(){
        self.enumerateChildNodes(withName: "Ground", using: ({
            (node,error) in
            print(node.name!)
            node.position.x-=2
            if node.position.x < -((self.scene?.size.width)!){
                node.position.x += (self.scene?.size.width)! * 3
                print(node.position.x)
            }
        }))
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            spMan.position.x = touch.location(in: self).x
            spMan.position.y = touch.location(in: self).y
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //spman.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
    }
    
    func createActor()
    {
        spMan = SKSpriteNode.init(imageNamed: "spaceman.png")
        bodySp.affectedByGravity=false
        
        bodySp.contactTestBitMask=ColliderType.SPAst.rawValue
        //bodySp.collisionBitMask=ColliderType.SPAst.rawValue
        bodySp.categoryBitMask=ColliderType.SPMan.rawValue
        
        spMan.physicsBody=bodySp
        spMan.position=CGPoint(x: 0, y: self.size.height/2-spMan.size.height/2)

        bgObject.addChild(spMan)
     
    }
    
    func createAsteroid()
    {
        spAst = SKSpriteNode.init(imageNamed: "Flare asteroid.png")
        spAst.position=CGPoint(x: 0, y:  -self.size.height/2+spAst.size.height/2)
        bodyAst.affectedByGravity=false
        
        bodyAst.categoryBitMask=ColliderType.SPAst.rawValue
        bodyAst.contactTestBitMask=ColliderType.SPMan.rawValue
        //bodyAst.collisionBitMask=ColliderType.SPMan.rawValue
        spAst.physicsBody=bodyAst
        
        bgObject.addChild(spAst)
        
    }
    
    func createBg(){
        bgTexture=SKTexture(imageNamed: "bkg.png")
        let moveBg=SKAction.moveBy(x: 0, y: -bgTexture.size().height, duration: 3)
        let replaceBg=SKAction.moveBy(x: 0, y: bgTexture.size().height, duration: 3)
        let moveBgForever=SKAction.repeatForever(SKAction.sequence([moveBg,replaceBg]))
        
        for i in 0..<3{
            bg=SKSpriteNode(texture: bgTexture)
            bg.position=CGPoint(x:0, y:  bg.size.height * CGFloat(i))
            bg.size.height = self.frame.height
            bg.size.width=self.frame.width
            bg.run(moveBgForever)
            bg.zPosition = -1
            bgObject.addChild(bg)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
            didCollide(spman: contact.bodyA.node as! SKSpriteNode, spast: contact.bodyB.node as! SKSpriteNode)
    }
    
    func didCollide(spman: SKSpriteNode, spast: SKSpriteNode)
    {
        spman.removeFromParent()
        spast.removeFromParent()
        print("Contact detected")
        
        let lb = SKLabelNode()
        lb.text="Boom boom"
        self.addChild(lb)
    }
    */
 
}
