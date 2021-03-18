//
//  saverView.swift
//  Pickup Sticks
//
//  Created by david reinfurt on 3/1/21.
//  Copyright © 2020 O-R-G inc. All rights reserved.
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
        
scene.physicsWorld.speed = 2.0  // 1.0 default ("real"time)

        // place the camera
        // first set rotation (eulerAngle)
        // then adjust position
        // (must be in that sequence)

        // plan view
        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        cameraNode.position = SCNVector3(x: 0, y: 30, z: 0)

        // off-axis front view
        // cameraNode.position = SCNVector3(x: 0, y: 10, z: 50)
        
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

        // add floor
        let floor = createFloor()
        scene.rootNode.addChildNode(floor)

        // add sticks
        for i in 0..<40 {
            let stick = createStick(size: CGFloat(5.0))
            scene.rootNode.addChildNode(stick)
        }

        // need to add pivot to change orientation before rotation ?
        // https://developer.apple.com/documentation/scenekit/scnnode/1408044-pivot
  
        // retrieve the SCNView
        let scnView = self.scnView
        
        // set the scene to the view
        scnView?.scene = scene
        
        // allows the user to manipulate the camera ( not needed on saver )
        // scnView?.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        // scnView?.showsStatistics = true
        
        // fixes low FPS if you need it
        // scnView?.antialiasingMode = .None
    }
    
    func createFloor() -> SCNNode {

        let floor = SCNBox(width: 100.0, height: 1.0, length: 100.0, chamferRadius: 0.0)        
        floor.firstMaterial?.diffuse.contents = NSColor(
                                red: 0.0,
                                green: 0.0,
                                blue: 0.0,
                                alpha: 1.0)
        let floorNode = SCNNode(geometry: floor)

        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)

        return floorNode
    }

    func createStick(size: CGFloat) -> SCNNode {

// should make size work in function

        var stick:SCNGeometry

        // width and height and length all effect gravity substantially
        stick = SCNBox(width: 0.02 * size, height: 0.02 * size, length: 6.0 * size, chamferRadius: 0.15)
        /*
        stick.firstMaterial?.diffuse.contents = NSColor(
                                red: .random(in: 0...1),
                                green: .random(in: 0...1),
                                blue: .random(in: 0...1),
                                alpha: 1.0)
        */
        /*
        let red = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        let green = NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        let blue = NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        let yellow = NSColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        */

        /*            
            r 86%, 31%, 26%
            g 21%, 48%, 25%
            b 16%, 47%, 70%
            y 93%, 87%, 34%
        */
        let red = NSColor(red: 0.86, green: 0.31, blue: 0.26, alpha: 1.0)
        let green = NSColor(red: 0.21, green: 0.48, blue: 0.25, alpha: 1.0)
        let blue = NSColor(red: 0.16, green: 0.47, blue: 0.70, alpha: 1.0)
        let yellow = NSColor(red: 0.93, green: 0.87, blue: 0.34, alpha: 1.0)

        let colorIndex = Int.random(in: 0...3)

        switch colorIndex {
        case 0:
            stick.firstMaterial?.diffuse.contents = red
        case 1:
            stick.firstMaterial?.diffuse.contents = green
        case 2:
            stick.firstMaterial?.diffuse.contents = blue
        case 3:
            stick.firstMaterial?.diffuse.contents = yellow
        default:
            stick.firstMaterial?.diffuse.contents = yellow
            // print("Some other character")
        }

        let stickNode = SCNNode(geometry: stick)
        stickNode.position = SCNVector3(x: 0, y: 5 * size, z: 0)
        stickNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        // nil in above sets the bounding box to match the given geometry

        // https://developer.apple.com/documentation/scenekit/scnphysicsbody/
        // more physics body settings
                
        stickNode.physicsBody?.restitution = 0.85   // ? try unwrap
        stickNode.physicsBody?.friction = 0.5   // 0.5 default

        // stickNode.physicsBody?.mass = 0.5   // 1.0 is default
        // stickNode.physicsBody!.restitution = 0.75   // ! force unwrap

        // position
        let randomDouble = Double.random(in: 1..<5)
        let rotation = CGFloat(Double.pi*2/randomDouble)
        // stickNode.position = SCNVector3(x: 0, y: offset, z: 0)
        // stickNode.rotation = SCNVector4(x: 0, y: 0, z: 1, w: .pi)
        // stickNode.runAction(SCNAction.rotateBy(x: .random(in: 0...1), y: .random(in: 0...1), z: 0, duration: 0.25))
        // stickNode.runAction(SCNAction.rotateBy(x: .random(in: 0...0.5), y: .random(in: 0...1), z: 0, duration: 0.25))
        // stickNode.runAction(SCNAction.rotateBy(x: .random(in: 0...0.5), y: .random(in: 0...0.5), z: 0, duration: 0.25))
        stickNode.runAction(SCNAction.rotateBy(x: 0, y: .random(in: -0.2...0.2), z: 0, duration: 0.05))
        // stickNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: -stickNodePosition, z: 0, duration: 12)))
        // stickNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: .random(in: 0...1), z: 0, duration: 0.25)))

        return stickNode
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
