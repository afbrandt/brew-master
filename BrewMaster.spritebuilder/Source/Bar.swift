//
//  Bar.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 5/26/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

class Bar: CCNode {

    var _spawnNode: CCNode!
    var _gameEndNode: CCNode!
    static var gameEndPoint: CGPoint = CGPointMake(0,0)
    
    var waitingCustomers: [Customer] = []
    
    var timeSinceSpawn: Double = 0.0
    var spawnDelay: Double = 5.0
    
    override func onEnter() {
        super.onEnter()
        Bar.gameEndPoint = _gameEndNode.positionInPoints
        
    }
    
    override func update(dt: CCTime) {
        timeSinceSpawn += dt
        
        if (timeSinceSpawn > spawnDelay) {
            println("spawn something")
            self.spawnCustomer()
            timeSinceSpawn = 0.0
        }
    }
    
    func spawnCustomer() {
        let customer = Customer.customerWithType(.StandardMale, withOrder: 1)
        customer.positionInPoints = _spawnNode.positionInPoints
        self.addChild(customer)
        waitingCustomers.append(customer)
    }

}