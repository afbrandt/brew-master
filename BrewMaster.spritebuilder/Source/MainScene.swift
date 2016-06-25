//
//  MainScene.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

class MainScene: CCNode {

    func startGameplay() {
        let gameplay = CCBReader.loadAsScene("Gameplay")
        CCDirector.sharedDirector().replaceScene(gameplay)
    }

}
