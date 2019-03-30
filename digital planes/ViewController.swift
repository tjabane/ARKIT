//
//  ViewController.swift
//  digital planes
//
//  Created by Tiisetso Tjabane on 2019/03/25.
//  Copyright © 2019 Tiisetso Tjabane. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


enum BodyType : Int{
    case box = 1
    case plane = 2
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView = ARSCNView(frame: self.view.frame);
        // Set the view's delegate
        sceneView.delegate = self
        
        self.view.addSubview(self.sceneView);
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        
        self.sceneView.debugOptions = [ ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin];
        
        let scene = SCNScene()
        
        registerGestureRecognizer()
        
        self.sceneView.scene = scene;

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration();
        configuration.planeDetection = .horizontal;

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor:ARAnchor )  {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor:ARAnchor )  {
        
        let plane = self.planes.filter{
            plane in
                return plane.anchor.identifier ==  anchor.identifier
        }.first
        
        if(plane == nil)
        {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
        
    }
    
    
    private func registerGestureRecognizer(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped));
        self.sceneView.addGestureRecognizer(tapGestureRecognizer);
    }
    
    
    @objc func tapped(recognizer: UITapGestureRecognizer){
        let sceneView = recognizer.view as! ARSCNView;
        let touchLocation = recognizer.location(in: sceneView);
        
        let hitRTestRetsult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent);
        
        if !hitRTestRetsult.isEmpty {
            guard let hitResult = hitRTestRetsult.first else{
                return
            }
            addBox(hitResult: hitResult)
        }
    }
    
    func addBox(hitResult: ARHitTestResult){
        let boxGeo = SCNBox(width: 0.2, height: 0.2 ,length: 0.2, chamferRadius: 0);
        let material = SCNMaterial()

        material.diffuse.contents = UIColor(red: CGFloat(arc4random_uniform(255)+1) / 255,
                                            green: CGFloat(arc4random_uniform(255) + 1) / 255,
                                            blue: CGFloat(arc4random_uniform(255) + 1) / 255,
                                            alpha: 1)
        boxGeo.materials = [material];
        
        let boxNode = SCNNode(geometry:boxGeo);
        boxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil);
        
        boxNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y + Float(boxGeo.height/2) + Float(0.5),
                                      hitResult.worldTransform.columns.3.z);
        
        boxNode.physicsBody?.categoryBitMask = BodyType.box.rawValue;
        
        self.sceneView.scene.rootNode.addChildNode(boxNode);
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
