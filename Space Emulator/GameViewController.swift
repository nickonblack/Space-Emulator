//
//  GameViewController.swift
//  Space Emulator
//
//  Created by Nikita Grigorchuk on 30.12.2018.
//  Copyright © 2018 Rusdev. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import AVFoundation

class GameViewController: UIViewController,SCNSceneRendererDelegate, AVAudioPlayerDelegate {

    var player: AVAudioPlayer?
    
    
    @IBOutlet weak var scnView: SCNView!
    var scnScene = SCNScene()
    let cameraNode = SCNNode()
    var sun: SCNNode!
    var planet: SCNNode!
    var sunMass:Float = 15.5
    var planetMass:Float = 4.0
    var planetVector = SCNVector3(0, 1.8, 0)
    var planetPos:SCNVector3?
    var lines : [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        createSun()
        createPlanet()
        setupCamera()
        playSound()
        setupLight()
        createLine()
        
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        player?.stop()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView()
    {
        scnView.delegate = self
    }
    
    func setupScene()
    {
        self.scnView.scene = scnScene
        scnScene.background.contents = UIImage(named:"art.scnassets/img_skybox.jpg")
        scnView.allowsCameraControl = true
        scnView.showsStatistics = true
    }
    
    func setupCamera()
    {
        cameraNode.camera = SCNCamera();
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 100
        cameraNode.position = SCNVector3Make(20, 20, 1000)
        cameraNode.eulerAngles = SCNVector3Make(-45,45,0)
        cameraNode.camera?.zFar = 10000
        
        let contraint = SCNLookAtConstraint(target: sun)
        contraint.isGimbalLockEnabled = true
        cameraNode.constraints = [contraint]
        scnScene.rootNode.addChildNode(cameraNode)
        
//      Для того чтобы следил за солнцем
//        sun.addChildNode(cameraNode )
    }
    
    func createSun()
    {
        let ballGeometry = SCNSphere(radius: 27)
        ballGeometry.segmentCount = 100
        sun = SCNNode(geometry: ballGeometry)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
        ballMaterial.emission.contents = UIImage(named:"art.scnassets/sun.jpg")
        ballMaterial.emission.intensity = 1
        ballGeometry.materials = [ballMaterial]
        
        sun.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat(2 * Double.pi), around: SCNVector3(0.2,1,0), duration: 20)))
        scnScene.rootNode.addChildNode(sun)
    }
    
    
    func createPlanet()
    {
        planet = SCNNode()
        let ballGeometry = SCNSphere(radius: 14.0)
        planet = SCNNode(geometry: ballGeometry)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor.gray
        ballGeometry.materials = [ballMaterial]
        planet.position = SCNVector3Make(60, 0 , 0 )
        scnScene.rootNode.addChildNode(planet)
    }
    
    func createLine()
    {
        ///
        let cyanMaterial = SCNMaterial()
        cyanMaterial.diffuse.contents = UIColor.cyan
        
        let anOrangeMaterial = SCNMaterial()
        anOrangeMaterial.diffuse.contents = UIColor.orange
        
        let aPurpleMaterial = SCNMaterial()
        aPurpleMaterial.diffuse.contents = UIColor.purple
        
        // A bezier path
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: -0.5, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: -0.25))
        bezierPath.addLine(to: CGPoint(x: 0.10, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0.15))
        bezierPath.close()
        
        // Add shape
//        let shape = SCNShape(path: bezierPath, extrusionDepth: 0.75)
//        shape.materials = [cyanMaterial, anOrangeMaterial, aPurpleMaterial]
//        let shapeNode = SCNNode(geometry: shape)
//        shapeNode.position = SCNVector3(x: 60, y: 0, z: 0);
//        //        self.rootNode.addChildNode(shapeNode)
//        shapeNode.rotation = SCNVector4(x: -1.0, y: -1.0, z: 0.0, w: 0.0)
//        scnScene.rootNode.addChildNode(shapeNode)
        //
//        bezierPath.move(to: CGPoint(x: -5, y: 0))
//        bezierPath.addLine(to: CGPoint(x: 0, y: -5))
//        bezierPath.addLine(to: CGPoint(x: 5, y: 0))
//        bezierPath.addLine(to: CGPoint(x: 0, y: 5))
//        bezierPath.close()
    }
    
    func distance(first :SCNNode, second :SCNNode)-> Float
    {
        let posX = pow(first.position.x - second.position.x,2)
        let posY = pow(first.position.y - second.position.y,2)
        let posZ = pow(first.position.z - second.position.z,2)
        return (sqrt(posX + posY + posZ))
    }
    
    
    
    func setupLight()
    {
        let light = SCNNode()
        light.light = SCNLight()
        light.light?.type = .ambient
        light.light?.intensity = 30
        scnScene.rootNode.addChildNode(light)
        
        sun.light = SCNLight()
        sun.light?.type = SCNLight.LightType.omni
        sun.light?.color = UIColor.white
    }
    
    func planetMove()
    {
        
        print("PositionX:",planet.position.x)
        print("PositionY:",planet.position.y)
        print("PositionZ:",planet.position.z)
        let vectorToSun = SCNVector3(sun.position.x - planet.position.x , sun.position.y - planet.position.y, sun.position.z - planet.position.z)
        let distToSun = distance(first: sun, second: planet)
        let vectorToSunNormalized = SCNVector3(vectorToSun.x/distToSun, vectorToSun.y/distToSun, vectorToSun.z/distToSun)
        let a = 11 * sunMass / distToSun / distToSun
        let finalVector = SCNVector3(a*vectorToSunNormalized.x, a*vectorToSunNormalized.y, a*vectorToSunNormalized.z)
        planetVector = SCNVector3(planetVector.x+finalVector.x, planetVector.y+finalVector.y, planetVector.z+finalVector.z)
        print(planetVector)
        
        
        if planetPos == nil
        {
            planetPos = planet.position
        }
        
        planetPos  = planet.position
        
        planet.runAction(SCNAction.moveBy(x: CGFloat(planetVector.x), y: CGFloat(planetVector.y), z: CGFloat(planetVector.z), duration: 0.1))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        planetMove()
        
        
        let line = SCNNode(geometry: SCNGeometry.lineFrom(vector: planetPos!, toVector: planet.position))
        lines.append(line)
        scnScene.rootNode.addChildNode(line)
        
    
        if lines.count > 500
        {
            lines.first?.removeFromParentNode()
            lines.remove(at: 0)
        }
    
        

        
    }
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "spaceMusic", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            player.delegate = self
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.play()
    }
    
    
    
    
    
    
    
    
}

extension SCNGeometry {
    class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
        
    }
}
//
//        // create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // create and add a camera to the scene
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        scene.rootNode.addChildNode(cameraNode)
//
//        // place the camera
//        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
//
//        // create and add a light to the scene
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light!.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene.rootNode.addChildNode(lightNode)
//
//        // create and add an ambient light to the scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = UIColor.darkGray
//        scene.rootNode.addChildNode(ambientLightNode)
//
//        // retrieve the ship node
//        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
//
//        // animate the 3d object
//        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
//
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // set the scene to the view
//        scnView.scene = scene
//
//        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
//
//        // show statistics such as fps and timing information
//        scnView.showsStatistics = true
//
//        // configure the view
//        scnView.backgroundColor = UIColor.black
//
//        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        scnView.addGestureRecognizer(tapGesture)
//    }
//
//    @objc
//    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // check what nodes are tapped
//        let p = gestureRecognize.location(in: scnView)
//        let hitResults = scnView.hitTest(p, options: [:])
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result = hitResults[0]
//
//            // get its material
//            let material = result.node.geometry!.firstMaterial!
//
//            // highlight it
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.5
//
//            // on completion - unhighlight
//            SCNTransaction.completionBlock = {
//                SCNTransaction.begin()
//                SCNTransaction.animationDuration = 0.5
//
//                material.emission.contents = UIColor.black
//
//                SCNTransaction.commit()
//            }
//
//            material.emission.contents = UIColor.red
//
//            SCNTransaction.commit()
//        }
//    }
//
//    override var shouldAutorotate: Bool {
//        return true
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
//
//}
