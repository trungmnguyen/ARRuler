//
//  ViewController.swift
//  ARRuler
//
//  Created by TRUNG NGUYEN on 1/14/19.
//  Copyright © 2019 TRUNG NGUYEN. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //Set Debug Option
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //        print("Touch Detected")
//        print(dotNodes.count)
        
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            
            dotNodes = [SCNNode]()
            textNode.removeFromParentNode()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
    }
    
    func addDot(at hitResult: ARHitTestResult){
        let dotGeometry = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        dotNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
        
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let dx = end.position.x - start.position.x
        let dy = end.position.y - start.position.y
        let dz = end.position.z - start.position.z
        
        let distance = sqrt(pow(dx,2) + pow(dy,2) + pow(dz,2))
        
        updateText(text: "\((distance*100).rounded()) cm",atPosition: end.position)
    }
    
    func updateText(text: String, atPosition: SCNVector3){
        
        
        let textGeometry = SCNText(string: text, extrusionDepth: 0.5)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black
        textGeometry.font = UIFont(name: "Cuckoo", size: 10)
        textNode = SCNNode(geometry: textGeometry)
        
        //        textNode.position = atPosition
        textNode.position = SCNVector3(atPosition.x,atPosition.y,atPosition.z)
        
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
        
        
    }
    
}
