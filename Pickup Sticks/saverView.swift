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
    var scene: SCNScene!
    var scale: CGFloat = 5.0
    var sticktotal: Int = 40   
    var sticksize: CGFloat = 5.0
    var pickuptime:TimeInterval = 0

    func prepareSceneKitView() {
        
        scene = SCNScene()
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        scene.physicsWorld.speed = 5.0  // 1.0 default ("real"time)
        // scene.physicsWorld.speed = 2.0  // 1.0 default ("real"time)
        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        cameraNode.position = SCNVector3(x: 0, y: 60, z: 0)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        lightNode.position = SCNVector3(x: 0, y: 25, z: 0)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        var floor = SCNNode()
        let floorGeometry = SCNFloor()
        floorGeometry.reflectivity = 0
        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = NSColor.black
        floorGeometry.materials = [floorMaterial]
        floor = SCNNode(geometry: floorGeometry)
        floor.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        scene.rootNode.addChildNode(floor)

        for i in 0..<sticktotal {
            let stick = createStick(size: sticksize) 
            scene.rootNode.addChildNode(stick)
        }
  
        let scnView = self.scnView
        scnView?.scene = scene
        
        scnView?.allowsCameraControl = true        
        scnView?.showsStatistics = true
        // scnView?.antialiasingMode = .None

        // renderloop hook 
        // https://stackoverflow.com/questions/35390959/scenekit-scnscenerendererdelegate-renderer-function-not-called
        scnView?.delegate = self

        // scnView?.playing = true      // optional unwap does not work
        scnView!.isPlaying = true       // force unwrap does, not sure why
    }

    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
                    
        // openGL performs better on SS + SceneKit w/ one monitor, but Metal (default) works best on two, so using Metal
        // let useopengl = [SCNView.Option.preferredRenderingAPI.rawValue: NSNumber(value: SCNRenderingAPI.openGLCore32.rawValue)]
        // self.scnView = SCNView.init(frame: self.bounds, options: useopengl)
        self.scnView = SCNView.init(frame: self.bounds)
        
        prepareSceneKitView()
        scnView.backgroundColor = NSColor.black
        
        self.addSubview(self.scnView)
    }
    
    required init?(coder: NSCoder) {

        super.init(coder: coder)
    }

    func createStick(size: CGFloat) -> SCNNode {

        var stick:SCNGeometry
        var point_l:SCNGeometry
        var point_r:SCNGeometry

        stick = SCNCylinder(radius: 0.03 * size, height: 12.0 * size)
        point_l = SCNCone(topRadius: 0.001 * size, bottomRadius: 0.03 * size, height: 1.0)
        point_r = SCNCone(topRadius: 0.03 * size, bottomRadius: 0.001 * size, height: 1.0)

        let red = NSColor(red: 0.86, green: 0.31, blue: 0.26, alpha: 1.0)
        let green = NSColor(red: 0.21, green: 0.48, blue: 0.25, alpha: 1.0)
        let blue = NSColor(red: 0.16, green: 0.47, blue: 0.70, alpha: 1.0)
        let yellow = NSColor(red: 0.93, green: 0.87, blue: 0.34, alpha: 1.0)
        let colorIndex = Int.random(in: 0...3)
        switch colorIndex {
            case 0:
                stick.firstMaterial?.diffuse.contents = red
                point_l.firstMaterial?.diffuse.contents = red
                point_r.firstMaterial?.diffuse.contents = red
            case 1:
                stick.firstMaterial?.diffuse.contents = green
                point_l.firstMaterial?.diffuse.contents = green
                point_r.firstMaterial?.diffuse.contents = green
            case 2:
                stick.firstMaterial?.diffuse.contents = blue
                point_l.firstMaterial?.diffuse.contents = blue
                point_r.firstMaterial?.diffuse.contents = blue
            case 3:
                stick.firstMaterial?.diffuse.contents = yellow
                point_l.firstMaterial?.diffuse.contents = yellow
                point_r.firstMaterial?.diffuse.contents = yellow
            default:
                stick.firstMaterial?.diffuse.contents = yellow
                point_l.firstMaterial?.diffuse.contents = yellow
                point_r.firstMaterial?.diffuse.contents = yellow
        }

        let stickNode = SCNNode(geometry: stick)
        let point_lNode = SCNNode(geometry: point_l)
        let point_rNode = SCNNode(geometry: point_r)
        stickNode.addChildNode(point_lNode)
        stickNode.addChildNode(point_rNode)
        stickNode.name = "stick"

        /* 
            position uses 4d vector (quaternion) to adjust rotation around 
            a 3d vector; last value is rotation, used to make stix more jumbled
        */

        let randomXoffset = CGFloat.random(in: -1...1)
        let randomZoffset = CGFloat.random(in: -1...1)
        let rotationExtent = CGFloat(Double.pi/Double.random(in: 1.25...2.0))

        point_lNode.position = SCNVector3Make(0, 6.1 * size, 0)
        point_rNode.position = SCNVector3Make(0, -6.1 * size, 0)

        stickNode.position = SCNVector3(x: randomXoffset, y: 20, z: randomZoffset)
        stickNode.rotation = SCNVector4Make(1, 0.25, 0.5, rotationExtent)

        stickNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        stickNode.physicsBody?.restitution = 0.1                
        stickNode.physicsBody?.friction = 0.5                   // 0.5 default
        stickNode.physicsBody?.mass = 1.0                       // 1.0 default

        // actions

        let randomDuration = Double.random(in: 1.0...3.0)        
        let fadeOut = SCNAction.fadeOut(duration: randomDuration)
        let fadeIn = SCNAction.fadeIn(duration: randomDuration/5.0)
        fadeOut.timingMode = .easeInEaseOut;
        fadeIn.timingMode = .easeInEaseOut;
        let removeFromParentNode = SCNAction.removeFromParentNode()
        let fadeSequence = SCNAction.sequence([fadeOut,fadeIn])
        let fadeRemoveSequence = SCNAction.sequence([fadeOut,fadeIn,removeFromParentNode])
        let fadeLoop = SCNAction.repeatForever(fadeSequence)
        
        stickNode.runAction(fadeSequence) {
        // stickNode.runAction(fadeRemoveSequence) {

            // .runAction(){ completion handler } called when action ends
            // cam also embed another action inside of this one 
            // which may likely be useful
        
            // trying to use SNNTransaction but setAnimationDuration 
            // somehow does not work here, but runs without duration
            SCNTransaction.begin()
            // SCNTransaction.setAnimationDuration(_: 2.5)
            stickNode.physicsBody?.mass = 0.0            
            // stickNode.opacity = 0.5
            SCNTransaction.commit()
            print("DONE")
        }

        /*
        stickNode.runAction(fadeRemoveSequence) {
            print("DONE")
        }
        */

        return stickNode
    }
    
    func updateSticks(number: Int) {

        let sticks = scene.rootNode.childNodes.filter({ $0.name == "stick" })
        if (sticks.count >= number) {
            for index in 0..<number {
                sticks[index].removeFromParentNode()
            }
        } else {
            for i in 0..<sticktotal {
                let stick = createStick(size: sticksize)
                scene.rootNode.addChildNode(stick)
            }
        }
    }
}

/*
    render lopp delegate 

    https://developer.apple.com/documentation/scenekit/scnaction    
    https://www.raywenderlich.com/1257-scene-kit-tutorial-with-swift-part-4-render-loop
*/

extension saverView: SCNSceneRendererDelegate {

    func renderer(_ renderer:SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > pickuptime {
            updateSticks(number: 1)
            pickuptime = time + TimeInterval(Float.random(in: 0.1...0.2))
        }
    }
}

