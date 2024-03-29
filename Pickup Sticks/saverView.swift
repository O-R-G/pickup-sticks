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
    var speed: CGFloat = 2.0    // 1.0 = realtime
    var sticks: [SCNNode] = []
    var sticktotal: Int = 40   
    var sticksize: CGFloat = 5.0
    var damping: CGFloat = 0.25
    var starttime: TimeInterval = 0.0
    var pickupstart: TimeInterval = 3.0
    var pickupfirst: TimeInterval = 6.0
    var pickupnext: TimeInterval = 0.0
    var pickupinterval: TimeInterval = 5.30769  // 5.175 * 39 + 6.0 = 213' = 3:33
    var pickup = false
    var stopping = false
    var debugtext: SCNText!
    var debug = false

    func prepareSceneKitView() {
        
        scene = SCNScene()
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        scene.physicsWorld.speed = speed  
        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        cameraNode.position = SCNVector3(x: 0, y: 60, z: 0)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        // lightNode.position = SCNVector3(x: 0, y: 25, z: 0)
        lightNode.position = SCNVector3(x: 0, y: 100, z: 0)
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

        for _ in 0..<sticktotal {
            let stick = createStick(size: sticksize) 
            scene.rootNode.addChildNode(stick)
        }
  
        if (debug) {
            // print() doesnt go to stdout in runner.app
            let debugtextnode = SCNNode()
            debugtext = SCNText(string: "** debug **", extrusionDepth: 1)
            debugtextnode.rotation = SCNVector4(-1, 0, 0, 1.5)
            debugtextnode.scale = SCNVector3(x:0.05, y:0.05, z:0.05)
            debugtextnode.geometry = debugtext
            scene.rootNode.addChildNode(debugtextnode)
            scnView?.allowsCameraControl = true        
            scnView?.showsStatistics = true
        }

        let scnView = self.scnView
        scnView?.scene = scene
        scnView?.delegate = self        // renderloop delegate
        scnView!.isPlaying = true       
    }

    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
                    
        // openGL performs better on SS + SceneKit w/ one monitor, but Metal (default) works best on two
        let useopengl = [SCNView.Option.preferredRenderingAPI.rawValue: NSNumber(value: SCNRenderingAPI.openGLCore32.rawValue)]
        self.scnView = SCNView.init(frame: self.bounds, options: useopengl)
        // self.scnView = SCNView.init(frame: self.bounds)
        
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
        stickNode.physicsBody?.angularDamping = damping         // 0.0 ... 1.0
        stickNode.physicsBody?.damping = damping

        return stickNode
    }

    func stopPhysics() {

        for index in 0..<sticks.count {
            sticks[index].physicsBody?.type = .static
        }
    }

    func sortSticks() {

        sticks = scene.rootNode.childNodes.filter({ $0.name == "stick" })   // better place to do this?
        sticks.sort {
            $0.presentation.worldPosition.y > $1.presentation.worldPosition.y
        }
    }

    func updateSticks(number: Int) {

        if (sticks.count >= number) {
            // pick-up
            for index in 0..<number {
                if (debug) {
                    // debugtext.string = String(describing: sticks[index].presentation.worldPosition.y)
                }
                sticks[index].removeFromParentNode()
            }
        } else {
            // drop
            for _ in 0..<sticktotal {
                let stick = createStick(size: sticksize)
                scene.rootNode.addChildNode(stick)
            }
            pickup = false
            starttime = 0.0
        }
    }
}

extension saverView: SCNSceneRendererDelegate {

    func renderer(_ renderer:SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        starttime = (starttime == 0.0) ? time : starttime
            
        if (time > starttime + pickupstart) {
            stopPhysics()
            sortSticks()
            stopping = true
        }

        if (stopping == true && time > starttime + pickupfirst) {
            pickup  = true
        } 

        if (pickup == true && time > pickupnext) {
            updateSticks(number: 1)
            pickupnext = time + pickupinterval
        }

        if (debug) {
            let currenttime = time - starttime
            debugtext.string = String(describing: currenttime) 
        }
    }
}
