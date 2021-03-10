//
//  saverView.swift
//  tetracono
//
//  Created by david reinfurt on 1/2/18.
//  Copyright © 2018 O-R-G inc. All rights reserved.
//
//  http://blog.viacom.tech/2016/06/27/making-a-macos-screen-saver-in-swift-with-scenekit/
//

import ScreenSaver
import SceneKit
import Foundation

class saverView: ScreenSaverView {
    
    var scnView: SCNView!
    var scale: CGFloat = 5.0
    var offset: CGFloat = 10.0   // stick y-offset from origin
    var sticks: Int = 50   // number of sticks
 
    func prepareSceneKitView() {
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        // first set rotation (eulerAngle)
        // then adjust position
        // (must be in that sequence)
        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        cameraNode.position = SCNVector3(x: 0, y: 25, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        lightNode.position = SCNVector3(x: 0, y: 25, z: 0)
        // lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        // add sticks
        // for _ in 0..<50 {
        for _ in 0..<sticks {
            let stickNode = createStickNode()
            scene.rootNode.addChildNode(stickNode)
        }
        
        // add floor ** todo **
        // so that sticks have somethig to land on
        let floorNode = createFloorNode()
        scene.rootNode.addChildNode(floorNode)

        // need to add pivot to change orientation before rotation
        // https://developer.apple.com/documentation/scenekit/scnnode/1408044-pivot
  
        // retrieve the SCNView
        let scnView = self.scnView
        
        // set the scene to the view
        scnView?.scene = scene
        
        // allows the user to manipulate the camera ( not needed on saver )
        scnView?.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView?.showsStatistics = true
        
        // fixes low FPS if you need it
        // scnView?.antialiasingMode = .None
    }
    
    func createStickNode() -> SCNNode {
        let stick = SCNBox(width: 0.025*scale, height: 0.025*scale, length: 3.0*scale, chamferRadius: 0.1)
        
        // color
        stick.firstMaterial?.diffuse.contents = NSColor(
                                red: .random(in: 0...1),
                                green: .random(in: 0...1),
                                blue: .random(in: 0...1),
                                alpha: 1.0)
        let stickNode = SCNNode(geometry: stick)
        
        // position
        let randomDouble = Double.random(in: 1..<5)
        let stickNodePosition = CGFloat(Double.pi*2/randomDouble)
        stickNode.position = SCNVector3(x: 0, y: offset, z: 0)
        // stickNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi)
        stickNode.runAction(SCNAction.rotateBy(x: 0, y: -stickNodePosition, z: 0, duration: 6))
        stickNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -stickNodePosition, z: 0, duration: 12)))
        
        // physics
        // https://developer.apple.com/documentation/scenekit/physics_simulation
        // https://developer.apple.com/documentation/scenekit/scnphysicsbody
        // https://www.raywenderlich.com/1258-scene-kit-tutorial-with-swift-part-3-physics
        
        // let location = touch.location(in: self)
        // let size = CGSize(width: 512, height: 2)
        // let stick = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        // stickNode.physicsBody = SCNPhysicsBody(rectangleOf: stick.size)
        // stickNode.physicsBody = SCNPhysicsBody()
        stickNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        // stickNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)

        // gravity? adjustment
        // doesnt seem to do anything
        // stickNode.physicsBody?.restitution = 0.05

        return stickNode
    }

    func createFloorNode() -> SCNNode {
        let floor = SCNBox(width: 100.0, height: 0.025, length: 100.0, chamferRadius: 0.0)
        
        // color
        floor.firstMaterial?.diffuse.contents = NSColor(
                                red: 0.25,
                                green: 0.25,
                                blue: 0.25,
                                alpha: 1.0)
        let floorNode = SCNNode(geometry: floor)
        
        // position
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // physics
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)

        return floorNode
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        //probably not needed, but cant hurt to check in case we re-use this code later
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        
        //initialize the sceneKit view
        /*
         // openGL performs better on SS + SceneKit w/ one monitor, but Metal (default) works best on two, so using Metal
         let useopengl = [SCNView.Option.preferredRenderingAPI.rawValue: NSNumber(value: SCNRenderingAPI.openGLCore32.rawValue)]
         self.scnView = SCNView.init(frame: self.bounds, options: useopengl)
         */
        self.scnView = SCNView.init(frame: self.bounds)
        
        //prepare it with a scene
        prepareSceneKitView()
        
        //set scnView background color
        scnView.backgroundColor = NSColor.black
        
        //add it in as a subview
        self.addSubview(self.scnView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
