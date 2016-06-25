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
    var counter: CCNode!
    var bartender: Bartender!
    
    static var gameEndPoint: CGPoint = CGPointMake(0,0)
    
    let state = GameState.sharedInstance
    var waitingCustomers: Set<Customer> = []
    
    var timeSinceSpawn: Double = 0.0
    var spawnDelay: Double = 3.5
    var emptyBar: Int = 0
    
    override func onEnter() {
        super.onEnter()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("regularMatch:"), name: MATCH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("largeMatch:"), name: LARGE_MATCH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("superMatch:"), name: SUPER_MATCH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gameOver:"), name: GAMEOVER, object: nil)
        Bar.gameEndPoint = _gameEndNode.positionInPoints
        counter.zOrder = BAR_DRAW_ORDER
    }
    
    override func onExit() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.onExit()
    }
    
    override func update(dt: CCTime) {
        timeSinceSpawn += dt
        
        if (timeSinceSpawn > spawnDelay) {
            print("spawn something")
            spawnCustomer()
            timeSinceSpawn = 0.0
        }
        
        if waitingCustomers.count == 0 {
            spawnCustomerWithOffset(10.0)
            spawnCustomerWithOffset(45.0)
            spawnCustomerWithOffset(70.0)
            emptyBar += 1
            spawnDelay *= 0.98
        }
    }
    
    func spawnCustomer() {
        let randomOffset = CGFloat(CCRANDOM_0_1() * 100)
        spawnCustomerWithOffset(randomOffset)
    }
    
    func spawnCustomerWithOffset(offset: CGFloat) {
        let customer = Customer.customerWithOrder(state.randomDrink())
        customer.positionInPoints = ccpAdd(_spawnNode.positionInPoints, ccp(-70.0, 0.0))
        let action = CCActionMoveTo(duration: 1.0, position: ccpAdd(_spawnNode.positionInPoints, ccp(offset, 0.0)))
        let actionFinished = CCActionCallFunc(target: customer, selector: Selector("actionFinished"))
        let moveSequence = CCActionSequence(array: [action, actionFinished])
        //customer.drinkOrder = "Beer"
        self.addChild(customer)
        waitingCustomers.insert(customer)
        customer.runAction(moveSequence)
    }
    
    func regularMatch(message: NSNotification) {
        let matchString = message.object as! String
        print("regular match")
        checkMatch(matchString, priority: .Regular)
    }
    
    func largeMatch(message: NSNotification) {
        let matchString = message.object as! String
        print("large match")
        checkMatch(matchString, priority: .Large)
    }
    
    func superMatch(message: NSNotification) {
        let matchString = message.object as! String
        print("super match")
        checkMatch(matchString, priority: .Super)
    }
    
    func checkMatch(matchString: String, priority: MatchPriority) {
        
        var closestCustomer: Customer! = nil
        var closestDistance: CGFloat = CGFloat.max
        //println(string)
        //checks for customer to serve based on match
        for customer in waitingCustomers {
            if customer.drinkOrder == matchString && customer.state != .Spawning {
                let distance = ccpDistance(Bar.gameEndPoint, customer.positionInPoints)
                if distance < closestDistance {
                    closestCustomer = customer
                    closestDistance = distance
                }
                //self.removeChild(customer)
                //waitingCustomers.remove(customer)
                //break;
            }
        }
        
        //removes served customer, if exists
        if let customer = closestCustomer {
//            self.removeChild(customer)
            waitingCustomers.remove(customer)
            timeSinceSpawn += 1.0
            
            switch priority {
                case .Regular:
                bartender.pendingOrders.append(customer)
                case .Large:
                bartender.pendingOrders.insert(customer, atIndex: 0)
                checkMatch(matchString, priority: .Regular)
                case .Super:
                bartender.pendingOrders.insert(customer, atIndex: 0)
                checkMatch(matchString, priority: .Super)
            }
//            NSNotificationCenter.defaultCenter().postNotificationName(SERVED, object: nil)
        }
    }
    
    func gameOver(message: NSNotification) {
        let customer = message.object as! Customer
        waitingCustomers.remove(customer)
        self.removeChild(customer)
    }

}