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
    
    var lines : [SCNNode] = []
    
    var planetsData : [(type: planetType, mass : Double, radius: Double, vector : SCNVector3, position: SCNVector3 )] = []
    var planets : [SCNNode] = []
    var planetPos: [SCNVector3] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupView()
        setupScene()
        createPlanets()
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
    
    
    
    func createPlanets()
    {
        for (_,planet) in planetsData.enumerated()
        {
            let ballGeometry = SCNSphere(radius: CGFloat(planet.radius))
            ballGeometry.segmentCount = 50
            let ball = SCNNode(geometry: ballGeometry)
            
            switch planet.type
            {
            case .sun:
                let ballMaterial = SCNMaterial()
                        ballMaterial.diffuse.contents = UIImage(named:"art.scnassets/sun.jpg")
                ballMaterial.emission.contents = UIImage(named:"art.scnassets/sun.jpg")
                            ballMaterial.emission.intensity = 1
                        ballGeometry.materials = [ballMaterial]
                ball.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat(2 * Double.pi), around: SCNVector3(0.2,1,0), duration: 20)))
            case .earth:
                let ballMaterial = SCNMaterial()
                ballMaterial.diffuse.contents = UIImage(named:"art.scnassets/earthmap.jpg")
                ballGeometry.materials = [ballMaterial]
            ball.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat(2 * Double.pi), around: SCNVector3(0.2,1,0), duration: 20)))
            case .planet:
                let ballMaterial = SCNMaterial()
                ballMaterial.diffuse.contents = UIImage(named:"art.scnassets/plutomap.jpg")
                ballGeometry.materials = [ballMaterial]
                ball.light = SCNLight()
                ball.light?.type = SCNLight.LightType.omni
                ball.light?.color = UIColor.white
                ball.runAction(SCNAction.repeatForever(SCNAction.rotate(by: CGFloat(2 * Double.pi), around: SCNVector3(0.2,1,0), duration: 20)))
            }
            ball.position = planet.position
            planets.append(ball)
            scnScene.rootNode.addChildNode(ball)
            
            self.planetPos.append(ball.position)
        }
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
        
        if planets.count > 0
        {
               let contraint = SCNLookAtConstraint(target: planets[0])
            contraint.isGimbalLockEnabled = true
            cameraNode.constraints = [contraint]
        }
        
        scnScene.rootNode.addChildNode(cameraNode)
        
//      Для того чтобы следил за солнцем
//        sun.addChildNode(cameraNode )
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
    }
   
    
    func planetsMove()
    {
        for i in 0...planetsData.count - 1
        {
           
            for j in 0...planetsData.count - 1
            {
               
               if i != j
               {
                    let vectorToOtherPlanet = SCNVector3((planets[j].position.x - planets[i].position.x) , (planets[j].position.y - planets[i].position.y), (planets[j].position.z - planets[i].position.z))
                    let distToOtherPlanet = distance(first: planets[i], second: planets[j])
                let vectorToOtherPlanetNormalized = SCNVector3(vectorToOtherPlanet.x/distToOtherPlanet, vectorToOtherPlanet.y/distToOtherPlanet, vectorToOtherPlanet.z/distToOtherPlanet)
                let a = 9.8 * Float(planetsData[j].mass) / distToOtherPlanet / distToOtherPlanet
                let finalVector = SCNVector3(a*vectorToOtherPlanetNormalized.x, a*vectorToOtherPlanetNormalized.y, a*vectorToOtherPlanetNormalized.z)
                planetsData[i].vector = SCNVector3(planetsData[i].vector.x+finalVector.x, planetsData[i].vector.y+finalVector.y, planetsData[i].vector.z+finalVector.z)
                }
                
            }
             planets[i].runAction(SCNAction.moveBy(x: CGFloat(planetsData[i].vector.x), y: CGFloat(planetsData[i].vector.y), z: CGFloat(planetsData[i].vector.z), duration: 0.1))
           
        }
    }
    
    func createLines()
    {
        
        for (index,_) in planetsData.enumerated()
        {
            debugPrint(planets[index].position)
            debugPrint(planetPos[index])
            let line = SCNNode(geometry: SCNGeometry.lineFrom(vector: planetPos[index], toVector: planets[index].position))
            lines.append(line)
            scnScene.rootNode.addChildNode(line)
            if lines.count > 500*planets.count
            {
                lines.first?.removeFromParentNode()
                lines.remove(at: 0)
            }
            planetPos[index] = planets[index].position
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        planetsMove()
        createLines()
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
    
    @IBAction func backBtnTouched(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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

enum planetType
{
    case sun
    case earth
    case planet
    
    func simpleDescription() -> String {
        switch self {
        case .sun:
            return "sun"
        case .earth:
            return "earth"
        case .planet:
            return "planet"
        }
    }
    
}
