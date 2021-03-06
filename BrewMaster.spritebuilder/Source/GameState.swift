//
//  GameState.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/4/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

class GameState: NSObject {
   
    //TODO: - Swift 1.2 implement as native Set
    var availableIngredients: [Ingredient] = [.Leaf, .Flower, .Stem, .Fruit, .Earth]
    
    var currentDrinkTypes: [String] = []
    var currentCustomerTypes: [String] = []
    var customerSpawnCap: Int = 0
    
    let audioMgr: OALSimpleAudio = OALSimpleAudio.sharedInstance()
    
    var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey(HIGHSCORE) {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey: HIGHSCORE)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var currentVenue: String = "" {
        didSet {
            //load from Plist, assign to drink types and customer type
            if let path = NSBundle.mainBundle().pathForResource("VenueDetails", ofType: "plist") {
                let src = NSDictionary(contentsOfFile: path)
                let details = src?[currentVenue] as! NSDictionary
                currentDrinkTypes = details["drinks"] as! [String]
                currentCustomerTypes = details["customers"] as! [String]
                customerSpawnCap = details["spawnCap"] as! Int
            }
        }
    }

    //Some tomfoolery to implement singletion pattern
//    class var sharedInstance: GameState {
//        struct Static {
//            static let instance: GameState = GameState()
//        }
//        return Static.instance
//    }
    static let sharedInstance: GameState = GameState()
    
    func randomAvailableIngredient() -> Ingredient {
        //let seed = UInt32(NSDate().timeIntervalSinceReferenceDate)
        //var index = Int(srand(seed)) % availableIngredients.count
        let index = Int(arc4random_uniform(5))
        return availableIngredients[index]
    }
    
    func randomDrink() -> String {
        let index = Int(CCRANDOM_0_1() * Float(currentDrinkTypes.count))
        return currentDrinkTypes[index]
    }
    
    func randomCustomer() -> String {
        let index = Int(CCRANDOM_0_1() * Float(currentCustomerTypes.count))
        return currentCustomerTypes[index]
    }
}
