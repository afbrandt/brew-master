//
//  Bar.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 5/26/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

let SERVED: String = "Served Customer"
let EMPTY_BAR: String = "Empty Bar"

class Bar: CCNode {

    var _spawnNode: CCNode!
    var _gameEndNode: CCNode!
    var counter: CCNode!
    
    static var gameEndPoint: CGPoint = CGPointMake(0,0)
    
    let state = GameState.sharedInstance
    var waitingCustomers: Set<Customer> = []
    
    var timeSinceSpawn: Double = 0.0
    var spawnDelay: Double = 5.0
    var emptyBar: Int = 0
    
    override func onEnter() {
        super.onEnter()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("checkMatch:"), name: MATCH, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gameOver:"), name: GAMEOVER, object: nil)
        Bar.gameEndPoint = _gameEndNode.positionInPoints
        counter.zOrder = BAR_DRAW_ORDER
    }
    
    override func onExit() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.onExit()
    }
    
    override func update(dt: CCTime) {
        //timeSinceSpawn += dt
        
        if (timeSinceSpawn > spawnDelay) {
            println("spawn something")
            spawnCustomer()
            timeSinceSpawn = 0.0
        }
        
        if waitingCustomers.count == 0 {
            spawnCustomer()
            emptyBar++
            spawnDelay -= 0.2
        }
    }
    
    func spawnCustomer() {
        let customer = Customer.customerWithOrder(state.randomDrink())
        customer.positionInPoints = _spawnNode.positionInPoints
        //customer.drinkOrder = "Beer"
        self.addChild(customer)
        waitingCustomers.insert(customer)
    }
    
    func checkMatch(message: NSNotification) {
        let matchString = message.object as! String
        var closestCustomer: Customer! = nil
        var closestDistance: CGFloat = CGFloat.max
        //println(string)
        //checks for customer to serve based on match
        for customer in waitingCustomers {
            if customer.drinkOrder == matchString {
                var distance = ccpDistance(Bar.gameEndPoint, customer.positionInPoints)
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
            self.removeChild(customer)
            waitingCustomers.remove(customer)
            NSNotificationCenter.defaultCenter().postNotificationName(SERVED, object: nil)
        }
    }
    
    func gameOver(message: NSNotification) {
        let customer = message.object as! Customer
        waitingCustomers.remove(customer)
        self.removeChild(customer)
    }

}