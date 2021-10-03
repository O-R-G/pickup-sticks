
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
    var sticks: Int = 40   

    /* init */

    func prepareSceneKitView() {
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        scene.physicsWorld.speed = 5.0  // 1.0 default ("real"time)
                                        // 5.0 dev

        // place the camera
        // first set rotation (eulerAngle)
        // then adjust position
        // (must be in that sequence)

        // plan view
        cameraNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        // cameraNode.position = SCNVector3(x: 0, y: 30, z: 0)
        cameraNode.position = SCNVector3(x: 0, y: 60, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.omni
        lightNode.eulerAngles = SCNVector3(x: -.pi/2, y: 0, z: 0);
        lightNode.position = SCNVector3(x: 0, y: 25, z: 0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLight.LightType.ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        // add floor
        let floor = createFloor(size: CGFloat(100.0))   
        scene.rootNode.addChildNode(floor)

        // add sticks
        for i in 0..<sticks {
            let stick = createStick(size: CGFloat(5.0)) 
            scene.rootNode.addChildNode(stick)
        }
  
        // retrieve the SCNView
        let scnView = self.scnView
        
        // set the scene to the view
        scnView?.scene = scene
        
        // allows the user to manipulate the camera ( not needed on saver )
        scnView?.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        // scnView?.showsStatistics = true
        
        // fixes low FPS if you need it
        // scnView?.antialiasingMode = .None

        // set up hook into renderloop for removing stix
        // https://stackoverflow.com/questions/35390959/scenekit-scnscenerendererdelegate-renderer-function-not-called

        // scnView?.delegate = self
        // scnView?.isPlaying = true
        // scnView?.loops = true
    }

    override init?(frame: NSRect, isPreview: Bool) {
        
        super.init(frame: frame, isPreview: isPreview)
        
        // not needed, but check in case we re-use later
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
                    
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


    /* geometry */

    func createFloor(size: CGFloat) -> SCNNode {

        // would be bset if this were a SCNFloor object which has no size
        // but somehow not working
        // let floor = SCNBox(width: 100.0, height: 1.0, length: 100.0, chamferRadius: 0.0)
        let floor = SCNBox(width: size, height: 1.0, length: size, chamferRadius: 0.0)
        // let floor = SCNPlane(width: 100.0, height: 100.0)
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

        var stick:SCNGeometry
        var point_l:SCNGeometry
        var point_r:SCNGeometry

        /* 
            width and height and length all effect gravity substantially
        */

        stick = SCNCylinder(radius: 0.03 * size, height: 12.0 * size)
        point_l = SCNCone(topRadius: 0.001 * size, bottomRadius: 0.03 * size, height: 1.0)
        point_r = SCNCone(topRadius: 0.03 * size, bottomRadius: 0.001 * size, height: 1.0)

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

        /*
            node (with children)
        */

        let stickNode = SCNNode(geometry: stick)

        let point_lNode = SCNNode(geometry: point_l)
        let point_rNode = SCNNode(geometry: point_r)

        stickNode.addChildNode(point_lNode)
        stickNode.addChildNode(point_rNode)

        /*
            position
 
            rotation uses 4d vector (quaternion) to adjust rotation around 
            a 3d vector; last value is how much to rotate, used to make 
            stix more jumbled
        */

        let randomXoffset = CGFloat.random(in: -1...1)
        let randomZoffset = CGFloat.random(in: -1...1)
        let rotationExtent = CGFloat(Double.pi/Double.random(in: 1.25...2.0))

        point_lNode.position = SCNVector3Make(0, 6.1 * size, 0)
        point_rNode.position = SCNVector3Make(0, -6.1 * size, 0)

        stickNode.position = SCNVector3(x: randomXoffset, y: 20, z: randomZoffset)
        stickNode.rotation = SCNVector4Make(1, 0.25, 0.5, rotationExtent)

        /*
            physics

            https://developer.apple.com/documentation/scenekit/scnphysicsbody/
        */

        stickNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        // stickNode.physicsBody?.restitution = 0.85            // ? try unwrap
        stickNode.physicsBody?.restitution = 0.1                
        stickNode.physicsBody?.friction = 0.5                   // 0.5 default
        stickNode.physicsBody?.mass = 1.0                       // 1.0 default
        // stickNode.physicsBody?.mass = 0.0                    // 0.0 means no movement
        // stickNode.physicsBody?.angularVelocityFactor = 0.0   // no rotation allowed

        /*
            animation

            1. stick falls
            2. after a while, stick stops moving (mass = 0.0)
            3. after a longer while, stick disappears

            https://stackoverflow.com/questions/29658772/animate-scnnode-forever-scenekit-swift
            https://stackoverflow.com/questions/40929527/check-if-scnnode-scnaction-is-finished
            this may be a mechanism for redrawing after it goes away
        */
        
        // let randomDuration = Double.random(in: 10.0...100.0)
        let randomDuration = Double.random(in: 1.0...3.0)
        
        let fadeOut = SCNAction.fadeOut(duration: randomDuration)
        let fadeIn = SCNAction.fadeIn(duration: randomDuration/5.0)
        fadeOut.timingMode = .easeInEaseOut;
        fadeIn.timingMode = .easeInEaseOut;
        let removeFromParentNode = SCNAction.removeFromParentNode()
        let fadeSequence = SCNAction.sequence([fadeOut,fadeIn])
        let fadeRemoveSequence = SCNAction.sequence([fadeOut,fadeIn,removeFromParentNode])
        let fadeLoop = SCNAction.repeatForever(fadeSequence)
        
        /*
        stickNode.runAction(fadeRemoveSequence) {
            stickNode.physicsBody?.mass = 0.0
            print("DONE")
        }
        */
                    
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
            stickNode.opacity = 0.5
            SCNTransaction.commit()
            print("DONE")
        }
        
        return stickNode
    }
    
    func testHook() {
        // scnView?.pause()
        scnView.backgroundColor = NSColor.red
        print("CALLED")
    }
}

/*
    delegate for hooking into render loop
    worth looking into how tetracono acheives this ... 
    or another swift 4 sceneKit screensaver
    or better, use an action to make stick disappear after a while
    and that action is set on the stick when it is made

    https://developer.apple.com/documentation/scenekit/scnaction    

    not currently working
*/

extension saverView: SCNSceneRendererDelegate {

    // deprecated?
    // func renderer(renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

    // still not being called ?
    func renderer(_ renderer:SCNSceneRenderer, updateAtTimet time:TimeInterval) {
        // spawnShape()
    
        print("called")
        testHook()

        // remove a stick (ie, a node)
        // https://developer.apple.com/documentation/scenekit/scnscenerendererdelegate
        // https://www.raywenderlich.com/1257-scene-kit-tutorial-with-swift-part-4-render-loop
    }
}

