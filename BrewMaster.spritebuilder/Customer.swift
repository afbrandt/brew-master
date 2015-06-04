//
//  Customer.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 5/26/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

enum CustomerType: Int {
    case StandardMale
}

class Customer: CCNode {

    var timeWaiting: Double = 0.0

    class func customerWithType(type: CustomerType, withOrder order: Int) -> Customer {
        let customer = CCBReader.load("Customer") as! Customer
        let sprite = CCBReader.load("Entity/Beer") as! CCSprite
        customer.addChild(sprite)
        return customer
    }

    func didLoadFromCCB() {
    
    }
    
    override func update(dt: CCTime) {
        timeWaiting += dt
        
        if (timeWaiting > 0.2) {
            let move = CCActionMoveBy(duration: 0.1, position: CGPointMake(9.0, 0))
            self.runAction(move)
            timeWaiting = 0
        }
        
        if (self.boundingBox().contains(Bar.gameEndPoint)) {
            println("left the scene!")
            self.removeFromParent()
        }
    }
}
