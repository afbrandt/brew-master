//
//  Customer.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 5/26/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

let GAMEOVER: String = "Game Over"

class Customer: CCNode {

    let state: GameState = GameState.sharedInstance
    var timeWaiting: Double = 0.0
    var actionDelay: Double = 1.0
    var moveDistance: Double = 4.0
    var drinkOrder: String = ""

    class func customerWithOrder(order: String) -> Customer {
        let customer = CCBReader.load("Customer") as! Customer
        let sprite = CCBReader.load("Entity/\(order)") as! CCSprite
        customer.drinkOrder = order
        customer.addChild(sprite)
        return customer
    }

    func didLoadFromCCB() {
        actionDelay = Double(CCRANDOM_0_1() + 0.5)
    }
    
    override func update(dt: CCTime) {
        timeWaiting += dt
        
        if (timeWaiting > actionDelay) {
            let distance = CGPointMake(CGFloat(moveDistance + Double(10.0 * CCRANDOM_0_1())), CGFloat(0.0))
            let move = CCActionMoveBy(duration: 0.1, position: distance)
            self.runAction(move)
            timeWaiting = 0
            if ccpDistance(self.positionInPoints, Bar.gameEndPoint) < 70 {
                println("closing in!")
                moveDistance = 0
            }
        }
        
        if (self.boundingBox().contains(Bar.gameEndPoint)) {
            //println("left the scene!")
            //self.removeFromParent()
            NSNotificationCenter.defaultCenter().postNotificationName(GAMEOVER, object: self)
        }
    }
}
