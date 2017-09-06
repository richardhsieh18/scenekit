//
//  GameViewController.swift
//  raywenSceneKit
//
//  Created by chang on 2017/9/6.
//  Copyright © 2017年 chang. All rights reserved.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    
    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        spwanShape()
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        scnView = self.view as! SCNView
        // 1
        scnView.showsStatistics = true
        // 2
        scnView.allowsCameraControl = true
        // 3
        scnView.autoenablesDefaultLighting = true
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 10)
        //
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spwanShape() {
        var geometry: SCNGeometry
        switch ShapeType.random() {
        case .sphere:
            geometry = SCNSphere(radius: 1.0)
        case .pyramid:
            geometry = SCNPyramid(width: 1.0, height: 1.0, length: 1.0)
        case .torus:
            geometry = SCNTorus(ringRadius: 1.0, pipeRadius: 1.0)
        case .capsule:
            geometry = SCNCapsule(capRadius: 1.0, height: 1.0)
        case .cylinder:
            geometry = SCNCylinder(radius: 1.0, height: 1.0)
        case .cone:
            geometry = SCNCone(topRadius: 1.0, bottomRadius: 1.0, height: 1.0)
        case .tube:
            geometry = SCNTube(innerRadius: 1.0, outerRadius: 1.0, height: 1.0)
        default:
            geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        }
        let geometryNode = SCNNode(geometry: geometry)
        //
        scnScene.rootNode.addChildNode(geometryNode)
        
    }

}
