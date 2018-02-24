//
//  MainMenuScene.swift
//  mario
//
//  Created by Bilal Qaiser on 10/02/2018.
//  Copyright © 2018 Bilal Qaiser. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "bakground")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
    
    func sceneTapped() {
        let myScene = GameScene(size: size)
        myScene.scaleMode = scaleMode
        let reveal = SKTransition.doorway(withDuration: 2.5)
        view?.presentScene(myScene, transition: reveal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        sceneTapped()
    }
    
}




