//
//  MainMenu.swift
//  CrazyCarts
//
//  Created by SuchyMac2 on 1/27/21.
//  Copyright © 2021 ITP. All rights reserved.
//

import Foundation
import SpriteKit

class LevelFailed: SKScene {
    
    var restartBtnNode:SKNode!
    var mainMenuBtnNode:SKNode!
    var scoreLabelNode:SKLabelNode!


    //Moved to GameOver.swift
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        // !IMPORTANT! Frames are not registered without isPaused = false!!
        self.isPaused = false
        setupStuff()
    }
    
    func setupStuff() {
        restartBtnNode = self.childNode(withName: "restartButtonNode")
        mainMenuBtnNode = self.childNode(withName: "mainMenuButtonNode")
        scoreLabelNode = self.childNode(withName: "scoreLabelNode") as? SKLabelNode
        scoreLabelNode.text = "SCORE: \(globalVariables.score) M"
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Loop over all the touches in this event
        for touch in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            // Restart Button
            if restartBtnNode.contains(location) {
                globalVariables.doCheckMenus = true
                globalVariables.restartButton = true 
            }
            //Main Menu Button
            if mainMenuBtnNode.contains(location) {
                globalVariables.doCheckMenus = true
                globalVariables.mainMenuButton = true
            }
        }
    }
}
