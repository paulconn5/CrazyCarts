//
//  GameViewController.swift
//  Crazy Carts iOS
//
//  Created by Paul Connolly on 3/19/21.
//

import UIKit
import SceneKit
import SpriteKit

//Global Variables to use between classes
 struct globalVariables {
    static var doCheckMenus = false
    //any gamemode active
    static var isRunning = false
    //the score
    static var score = 0
    //the level
    static var level = 40
    //freeplay
    static var isPlayingFreeplay = false
    //Buttons
    static var levelButton = false
    static var mainMenuButton = false
    static var restartButton = false
    static var freeplayButton = false
}

class GameViewController: UIViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    //The Scene
    var sceneView:SCNView!
    var scene:SCNScene!
    
    //Physics Collision Handler
    var physicsWorld:SCNPhysicsWorld!
    
    // Nodes
    var cartNode:SCNNode!
    var cameraNode:SCNNode!
    var floorNode:SCNNode!
    var omniLightNode:SCNNode!
    var box:SCNNode!
    var aisleNodes:SCNNode!
    var emptyAisleNode:SCNNode!
    
    //Map Node Arrays
    var obstacles: [SCNNode] = []
    var groceries: [SCNNode] = []
    var aisles: [SCNNode] = []
    
    //Player Events
    var isMoving = false
    var isJumping = false
    var hasCollided = false

    
    //Cart position in the lanes
    var cartPosition = 2
    //Speed for forward movements (cart, camera, death velocity)
    var moveSpeed = 8.0
    
    //Generators
    //Send a request for the map to preload
    var doMapLoad = false
    //How far should the map preload?
    var preloadDistance = 35
    //How often to place a new aisle on each side
    var aisleInterval = 0.0
    
    override func viewDidLoad() {
        
        setupScene()
        setupNodes()
        doMapLoad = true
   //     sceneView.overlaySKScene = SKScene(fileNamed: "SKOverlays/MainMenuOverlay.sks")
        
        
        // Show statistics such as fps and timing information
        self.sceneView.showsStatistics = true
        
        // User Inputs
        // Swipe Left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(gestureResponse))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Swipe Right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(gestureResponse))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        // Swipe Up
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(gestureResponse))
        swipeRight.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
    }
    
    func setupScene() {
        sceneView = (self.view as! SCNView)
        scene = SCNScene(named: "art.scnassets/MainScene.scn")
        sceneView.scene = scene
        sceneView.delegate = self
        scene.physicsWorld.contactDelegate = self
    }
    
    func setupNodes() {
        //Cart
        cartNode = scene.rootNode.childNode(withName:  "cart", recursively: true)
        cartNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        //Important, tells the physics engine to check for all types of collisions
        cartNode.physicsBody!.contactTestBitMask = cartNode.physicsBody!.collisionBitMask
        box = scene.rootNode.childNode(withName:  "box", recursively: true)
        box.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        //Camera
        cameraNode = scene.rootNode.childNode(withName: "camera", recursively: true)
        omniLightNode = scene.rootNode.childNode(withName: "omniLight", recursively: true)
        //Aisles
        aisleNodes = scene.rootNode.childNode(withName: "aisles", recursively: true)
        emptyAisleNode = scene.rootNode.childNode(withName: "emptyAisle", recursively: true)
        
    }
    
    //GESTURE MOVEMENT CONTROLLER

    @objc func gestureResponse(gesture: UIGestureRecognizer) {
        
        //Individual Moves
        let moveLeft = SCNAction.moveBy(x: 1, y: 0.0, z: 0, duration: 0.35)
        let moveRight = SCNAction.moveBy(x: -1, y: 0.0, z: 0, duration: 0.35)
        let moveUp = SCNAction.moveBy(x: 0, y: 0.5, z: 0, duration: 0.75)
        let moveDown = SCNAction.moveBy(x: 0, y: -0.5, z: 0, duration: 0.5)
        let moveFinish: SCNAction = SCNAction.customAction(duration: 0, action: {_,_ in self.isMoving = false})
        let jumpFinish: SCNAction = SCNAction.customAction(duration: 0, action: {_,_ in self.isJumping = false})
        
        //Move Sequences
        let leftSequence = SCNAction.sequence([moveLeft, moveFinish])
        let rightSequence = SCNAction.sequence([moveRight, moveFinish])
        let jumpSequence = SCNAction.sequence([moveUp, moveDown, jumpFinish])
        
    
        // Actions for gesture swipes.
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
  
                switch swipeGesture.direction {
                case .left:
                    if isMoving == false && cartPosition > 1 {
                        isMoving = true
                        cartPosition = cartPosition-1
                        cartNode.runAction(leftSequence)
                        cameraNode.runAction(leftSequence)
                    }
                case .right:
                    if isMoving == false && cartPosition < 3 {
                        isMoving = true
                        cartPosition = cartPosition+1
                        cartNode.runAction(rightSequence)
                        cameraNode.runAction(rightSequence)
                    }
                case .up:
                    if isJumping == false {
                        isJumping = true
                        cartNode.runAction(jumpSequence)
                    }
                default:
                    break
                }
            }
        }

    //Move the cart and camera forward constantly
    func moveNodesForward() {
        let moveUpdater = SCNAction.move(by: SCNVector3(0,0,moveSpeed), duration: 1 )
        let repeatUpdater = SCNAction.repeatForever(moveUpdater)
        cameraNode.runAction(repeatUpdater)
        omniLightNode.runAction(repeatUpdater)
        cartNode.runAction(repeatUpdater)
    }
    
    //Collision Detection For Obstacles and Groceries
     func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
            //If the cart interacts with ...
            if contact.nodeA.name == "cart" {
                // an obstacle
                if contact.nodeB.name == "box" {
                    cartNode.removeAllActions()
                    cameraNode.removeAllActions()
                    omniLightNode.removeAllActions()
                    cartNode.physicsBody?.velocity.z = Float(moveSpeed)
                // a grocery
                } else if contact.nodeB.name == "grocery" {
                    contact.nodeB.removeFromParentNode()
                }
            }
    }
    func generateAisles() {
        aisleInterval += 4.8
        let leftAisleGenerator = emptyAisleNode.clone()
        leftAisleGenerator.position = SCNVector3Make(2.2, 0, Float(aisleInterval))
        self.aisleNodes.addChildNode(leftAisleGenerator)
        aisles.append(leftAisleGenerator)
        let rightAisleGenerator = emptyAisleNode.clone()
        rightAisleGenerator.eulerAngles = SCNVector3(1.5707964,-4.712389,0)
        rightAisleGenerator.position = SCNVector3Make(-2.2, 0, Float(aisleInterval))
        self.aisleNodes.addChildNode(rightAisleGenerator)
        aisles.append(rightAisleGenerator)
    }
    
    //Aisle Degenerator
    func degenerateAisles() {
        if aisles.count > 0 && aisles[0].position.z < cartNode.position.z {
        aisles[0].removeFromParentNode()
        aisles.removeFirst()
        }
    }

    func checkMenus() {
        //CLICKED 'LEVEL _"
        if globalVariables.levelButton == true {
            globalVariables.levelButton = false
            isMapReady()
        }
        
        //Clicked "Main Menu"
        if globalVariables.mainMenuButton == true {
            globalVariables.mainMenuButton = false
      //      sceneView.overlaySKScene = SKScene(fileNamed: "MainMenuScene")
        }
        
        //Clicked "restart"
        if globalVariables.restartButton == true {
            globalVariables.restartButton = false
            if globalVariables.isPlayingFreeplay == true {
    //            freeplaySetup()
            }
            else {
    //            levelSetup()
            }
        }
        //Clicked "freeplay"
        if globalVariables.freeplayButton == true {
            globalVariables.freeplayButton = false
        //    freeplaySetup()
        }
    }
    
    func levelSetup() {
        scene.isPaused = false
        moveNodesForward()
    }
    
    func isMapReady() {
        if doMapLoad == false {
            if globalVariables.isPlayingFreeplay == true {
                return
            } else {
                levelSetup()
            }
        }
    }
    

    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

