//
//  MainMenu.swift
//  CrazyCarts
//
//  Created by SuchyMac2 on 1/27/21.
//  Copyright © 2021 ITP. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class LevelStats: SKScene {
    
    var skScore:SKLabelNode!
  
    
    //Moved to GameSceneOverlay.sks
    override func didMove(to view: SKView) {
        scaleMode = .fill
        // !IMPORTANT! Frames are not registered without isPaused = false!!
        self.isPaused = false
        setupStuff()

    }
    
    //Setting up node
    func setupStuff() {
        skScore = self.childNode(withName: "skScoreNode") as? SKLabelNode
    }
    

    //Updates once a frame
    override func update(_ currentTime: TimeInterval) {
        //Updates score
        skScore.text = "\(globalVariables.score) M"
    }
    
}
