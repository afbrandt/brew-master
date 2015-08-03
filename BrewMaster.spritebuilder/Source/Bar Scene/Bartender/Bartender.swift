//
//  Bartender.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 8/2/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

enum BartenderState {
    case Idle, Serving, Panicking
}

class Bartender: CCNode {
    
    var pendingOrders: [Customer] = []
    
    var state: BartenderState = .Idle
    var timeWaiting: Double = 0.0
    
    override func update(delta: CCTime) {
        
        switch state {
        case .Idle:
            if !pendingOrders.isEmpty {
                state = .Serving
                serve()
            } else {
                
            }
        case .Serving:
            timeWaiting = 0.0
        case .Panicking:
            timeWaiting = 0.0
        }
    }
    
    func actionFinished() {
        if !pendingOrders.isEmpty {
            serve()
            return
        }
        
        switch state {
        case .Idle:
            state = .Idle
        case .Serving:
            state = .Idle
            animationManager.runAnimationsForSequenceNamed("ShowIdle")
        case .Panicking:
            state = .Idle
        }
    }
    
    func serve() {
    
        let customer = pendingOrders.removeAtIndex(0)
        let drink = CCBReader.load("Entity/\(customer.drinkOrder)") as! CCSprite
        
        drink.positionInPoints = self.positionInPoints
        drink.scale = 0.7
        drink.zOrder = BAR_DRAW_ORDER
        customer.catchDrink(drink)
        animationManager.runAnimationsForSequenceNamed("ShowServing")
        
    }
    
    
}