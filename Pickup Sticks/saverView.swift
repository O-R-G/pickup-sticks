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
    var sticks: Int = 40   // number of sticks
        
    // create a new scene ----> scope! (see below)
    let scene = SCNScene()

    func prepareSceneKitView() {
        
        // create a new scene
        // let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // scene.physicsWorld.speed = 0.25  // 1.0 default ("real"time)
        // scene.physicsWorld.speed = 0.5  // 1.0 default ("real"time)
        // scene.physicsWorld.speed = 1.0  // 1.0 default ("real"time)
        // scene.physicsWorld.speed = 2.0  // 1.0 default ("real"time)
        scene.physicsWorld.speed = 4.0  // 1.0 default ("real"time)

        // place the camera
        // first set rotation (eulerAngle)
        // then adjust position
        // (must be in that sequence)

        // plan view
        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        cameraNode.position = SCNVector3(x: 0, y: 30, z: 0)
        
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
        let floor = createFloor()   // no need to return anything here, maybe true or nothing?
        // scene.rootNode.addChildNode(floor)

        // add sticks
        for i in 0..<sticks {
            let stick = createStick(size: CGFloat(5.0)) // return only true or nothing?
            // scene.rootNode.addChildNode(stick)
        }

        // need to add pivot to change orientation before rotation ?
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

        // set up hook into renderloop for removing stix
        // https://stackoverflow.com/questions/35390959/scenekit-scnscenerendererdelegate-renderer-function-not-called

        scnView?.delegate = self
        scnView?.isPlaying = true
        scnView?.loops = true
    }
    
    func createFloor() -> SCNNode {

        let floor = SCNBox(width: 100.0, height: 1.0, length: 100.0, chamferRadius: 0.0)
        // let floor = SCNPlane(width: 100.0, height: 100.0)
        floor.firstMaterial?.diffuse.contents = NSColor(
                                red: 0.1,
                                green: 0.1,
                                blue: 0.1,
                                alpha: 1.0)
        /*
        // just for dev render loop (renderer as delegate)
        floor.firstMaterial?.diffuse.contents = NSColor(
                                red: CGFloat.random(in: 0.1...0.5),
                                green: CGFloat.random(in: 0.1...0.5),
                                blue: CGFloat.random(in: 0.1...0.5),
                                alpha: 1.0)
        */
        let floorNode = SCNNode(geometry: floor)

        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        floorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)

        scene.rootNode.addChildNode(floorNode)

        return floorNode
    }

    func createStick(size: CGFloat) -> SCNNode {

        var stick:SCNGeometry

        /* 
            geometry
            
            width and height and length all effect gravity substantially
        */

        stick = SCNCapsule(capRadius: 0.03 * size, height: 6.0 * size)

        /*
            color

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
        }

        /*
            node
        */

        let stickNode = SCNNode(geometry: stick)

        /*
            position

            two options: perpindicular or parallel

            rotation uses 4d vector (quaternion) to adjust rotation around a 3d vector
            last value is how much to rotate, used to make the stix more jumbled
        */

        let perpindicular = false
        let randomXoffset = CGFloat.random(in: -1...1)
        let randomZoffset = CGFloat.random(in: -1...1)
        let rotationExtent = CGFloat(Double.pi/Double.random(in: 1.25...2.0))

        if perpindicular {
            stickNode.position  = SCNVector3(x: randomXoffset, y:0.1, z: randomZoffset)
        } else {
            stickNode.position = SCNVector3(x: randomXoffset, y: 50, z: randomZoffset)
            stickNode.rotation = SCNVector4Make(1, 0.25, 0.5, rotationExtent)
        }

        /*
            physics

            https://developer.apple.com/documentation/scenekit/scnphysicsbody/
        */

        stickNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)                
        stickNode.physicsBody?.restitution = 0.85   // ? try unwrap
        stickNode.physicsBody?.friction = 0.5       // 0.5 default
        stickNode.physicsBody?.mass = 1.0           // 1.0 is default

        scene.rootNode.addChildNode(stickNode)

        return stickNode
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        /*
        // not needed, but check in case we re-use later
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        */
                    
        // initialize the sceneKit view
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

    func testHook() {
        // scnView?.pause()
        scnView.backgroundColor = NSColor.red
    }
}

// delegate for hooking into render loop
// worth looking into how tetracono acheives this ... 
// or another swift 4 sceneKit screensaver

extension saverView: SCNSceneRendererDelegate {

    // deprecated?
    // func renderer(renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

    // still not being called
    func renderer(_ renderer:SCNSceneRenderer, updateAtTimet time:TimeInterval) {
        // spawnShape()
        // let floor = createFloor()   // no need to return anything here
        // let stick = createStick(size: CGFloat(5.0))
    
        testHook()

        // remove a stick (ie, a node)
        // https://developer.apple.com/documentation/scenekit/scnscenerendererdelegate
        // https://www.raywenderlich.com/1257-scene-kit-tutorial-with-swift-part-4-render-loop
    }
}


