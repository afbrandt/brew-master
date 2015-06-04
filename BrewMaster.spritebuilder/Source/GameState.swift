//
//  GameState.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/4/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

var currentState: GameState!

class GameState: NSObject {
   
    //TODO: - Swift 1.2 implement as native Set
    var availableIngredients: [Ingredient] = [.Leaf, .Flower, .Stem, .Fruit, .Earth]
    let audioMgr: OALSimpleAudio = OALSimpleAudio.sharedInstance()
    
    //Some tomfoolery to implement singletion pattern
    class var sharedInstance: GameState {
        struct Static {
            static let instance: GameState = GameState()
        }
        return Static.instance
    }
    
    func randomAvailableIngredient() -> Ingredient {
        //let seed = UInt32(NSDate().timeIntervalSinceReferenceDate)
        //var index = Int(srand(seed)) % availableIngredients.count
        var index = Int(arc4random_uniform(5))
        return availableIngredients[index]
    }
}
