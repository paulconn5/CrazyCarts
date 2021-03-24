//
//  MainMenu.swift
//  CrazyCarts
//
//  Created by SuchyMac2 on 1/27/21.
//  Copyright © 2021 ITP. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    var skLevelBtn:SKNode!
    var skFreeplayBtn:SKNode!
    var skLevelText:SKLabelNode!


    //Moved to MainMenuScene.sks
    override func didMove(to view: SKView) {
        scaleMode = .aspectFill
        // !IMPORTANT! Frames are not registered without isPaused = false!!
        self.isPaused = false
        setupStuff()
    }
    
    func setupStuff() {
        skLevelBtn = self.childNode(withName: "skLevelBtnNode")
        skFreeplayBtn = self.childNode(withName: "skFreeplayBtnNode")
        skLevelText = skLevelBtn.childNode(withName: "skLevelText") as? SKLabelNode
        skLevelText.text = "LEVEL \(globalVariables.level)"
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Loop over all the touches in this event
        for touch in touches {
            // Get the location of the touch in this scene
            let location = touch.location(in: self)
            // Level BTN
            if skLevelBtn.contains(location) {
                globalVariables.doCheckMenus = true
                globalVariables.levelButton = true
            }
            // FREEPLAY BTN
            if skFreeplayBtn.contains(location) {
                globalVariables.doCheckMenus = true
                globalVariables.freeplayButton = true
            }
        }
    }
}
