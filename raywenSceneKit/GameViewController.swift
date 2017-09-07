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
    //設定更新時間
    var spawnTime: TimeInterval = 0
    //Helper的寫法
    var game = GameHelper.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
        setupCamera()
        //spawnShape()
        setupHUD()
    }
    //裝置可以旋轉
    override var shouldAutorotate: Bool {
        return true
    }
    //滑動時狀態列會隱藏
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //把view向下轉型成SCNView
    func setupView() {
        scnView = self.view as! SCNView
        // 1 秀出scene的狀態
        scnView.showsStatistics = true
        // 2 允許控制camera //遊戲設定完畢後改為False
        scnView.allowsCameraControl = false
        // 3 允許自動加上光線
        scnView.autoenablesDefaultLighting = true
        //scnview的代理為gameviewcontroller
        scnView.delegate = self
        scnView.isPlaying = true
    }
    //建立scene場景
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        //scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
    }
    //設定相機的node位置在Scene裡x,y,z，設定完要加入scene場景的rootnode裡
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 5, 10)
        //
        scnScene.rootNode.addChildNode(cameraNode)
    }
    //設定Shape，另建一個ShapeType的class
    func spawnShape() {
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
        //L3 幫geometry加上顏色 L5 生個變數小修改一下
        let color = UIColor.random()
        geometry.materials.first?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
        //print(geometryNode)
        //加上物理特性，type有三種，static,dynamic,Kinematic
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //設定x,y為random
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        //設定力量強度
        let force = SCNVector3Make(randomX, randomY, 0)
        //力量按下去的位置
        let position = SCNVector3Make(0.05, 0.05, 0.05)
        //asimpulse 衝擊力為true才會有跳動
        geometryNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        //L5建立個 SCNParticleSystem在geometryNode掛上去
        let trailEmitter = createTrail(color: color, geometry: geometry)
        geometryNode.addParticleSystem(trailEmitter)
        if color == UIColor.black {
            geometryNode.name = "BAD"
        } else {
            geometryNode.name = "GOOD"
        }
        
        
        
        //最後把shape的node加在rootnote裡
        scnScene.rootNode.addChildNode(geometryNode)
    }
    
    func cleanScene() {
        //在scene下的子node陣列裡
        for node in scnScene.rootNode.childNodes {
            //如果node的y軸小於-2
            if node.presentation.position.y < -2 {
                //就移除掉該node
                node.removeFromParentNode()
            }
        }
    }
    //L5 加特效，先加了ScnParticalSystem的file
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let trail = SCNParticleSystem(named: "Trail.scnp", inDirectory: nil)!
        trail.particleColor = color
        trail.emitterShape = geometry
        return trail
    }
    //L5 設立計分板
    func setupHUD() {
        game.hudNode.position = SCNVector3Make(0.0, 10.0, 0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    //L5 點擊事件好壞之分
    func handleTouchFor(node: SCNNode) {
        if node.name == "GOOD" {
            game.score += 1
            //爆炸事件
            createExplosion(geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
            node.removeFromParentNode()
        } else if node.name == "BAD" {
            game.lives -= 1
            //爆炸事件
            createExplosion(geometry: node.geometry!, position: node.presentation.position, rotation: node.presentation.rotation)
            node.removeFromParentNode()
        }
    }
    //常用的touch事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touch陣列的第一個
        let touch = touches.first!
        //touch的location在scnview上
        let location = touch.location(in: scnView)
        //scnView的hitTest方法，位置為scnView的locaiton，找兩個View的交集
        let hitResults = scnView.hitTest(location, options: nil)
        //如果有觸發到scnView的hitTest方法
        if let result = hitResults.first {
            //判斷加分或扣分
            handleTouchFor(node: result.node)
        }
    }
    //Explosion效果
    func createExplosion(geometry: SCNGeometry, position: SCNVector3, rotation: SCNVector4) {
        let explosion = SCNParticleSystem(named: "Explode.scnp", inDirectory: nil)!
        explosion.emitterShape = geometry
        //explosion的位置
        explosion.birthLocation = .surface
        //旋轉
        let rotationMatrix = SCNMatrix4MakeRotation(rotation.w, rotation.x, rotation.y, rotation.z)
        //位置
        let translationMatrix = SCNMatrix4MakeTranslation(position.x, position.y, position.z)
        //
        let transformMatrix = SCNMatrix4Mult(rotationMatrix, translationMatrix)
        scnScene.addParticleSystem(explosion, transform: transformMatrix)
    }
    
    
}
//SCNSceneRender代理
extension GameViewController: SCNSceneRendererDelegate {
    //1
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //當time大於0的時候，更新spawnTime
        if time > spawnTime {
            spawnShape()
            // time加上隨機數，來決定true of false
            spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
        }
        //清除子node
        cleanScene()
        game.updateHUD()
    }
    
}
