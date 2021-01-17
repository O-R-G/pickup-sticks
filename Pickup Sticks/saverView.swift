//
//  saverView.swift
//

//  Created by Eric Li on 1/23/19.
//  Copyright © 2019 O-R-G inc. All rights reserved.
//
//  http://blog.viacom.tech/2016/06/27/making-a-macos-screen-saver-in-swift-with-scenekit/
//

import ScreenSaver
import SpriteKit

class saverView: ScreenSaverView {
    
    var spriteView: SKView!
    
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        //initialize the spriteKit view
        self.spriteView = SKView(frame: frame)
        let scene = SKScene(size: frame.size)
        scene.backgroundColor = .black
        
        self.addNew(scene: scene)
        
        for _ in 0..<50 {
            self.addStick(scene: scene)
        }
        
        
        //add it in as a subview
        self.spriteView.presentScene(scene)
        self.addSubview(self.spriteView)
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func addNew(scene: SKScene) {
        self.addStick(scene: scene)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.addNew(scene: scene)
        }
    }
    
    func addStick(scene: SKScene) {
        let height = self.spriteView.frame.size.height
        let width = self.spriteView.frame.size.width
        
        let length = Double(height/2)
        let x = Double.random(in:  0 ..< Double(width))
        let y = Double.random(in:  0 ..< Double(height))
        let rotation = Double.random(in:  0 ..< .pi)
        
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: x, y: y))
        linePath.addLine(to: CGPoint(x: length*cos(rotation)+x, y: length*sin(rotation)+y))
        
        let sprite = SKShapeNode(path: linePath, centered: true)
        sprite.strokeColor = NSColor(
                                red: .random(in: 0...1),
                                green: .random(in: 0...1),
                                blue: .random(in: 0...1),
                                alpha: 1.0)
        
        sprite.lineWidth = 5.0
        sprite.lineCap = .round
        
        let xNew = Double.random(in:  0 ..< Double(width))
        let yNew = Double.random(in:  0 ..< Double(height))
        let rotationNew = Double.random(in:  0 ..< .pi)
        
        let moveAction = SKAction.move(to: CGPoint(x: xNew, y: yNew), duration: 1)
        let rotateAction = SKAction.rotate(byAngle: CGFloat(rotationNew), duration: 1)
        moveAction.timingMode = .easeOut
        rotateAction.timingMode = .easeOut
        
        sprite.run(moveAction)
        sprite.run(rotateAction)
        
        scene.addChild(sprite)
        
    }
}
