//
//  Customer.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 5/26/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

let GAMEOVER: String = "Game Over"

enum CustomerState {
    case Spawning, Ordering, Moving, Drinking, Idle, Angry
}

class Customer: CCNode {

    let gameState: GameState = GameState.sharedInstance
    var state: CustomerState = .Spawning
    var timeWaiting: Double = 0.0
    var actionDelay: Double = 1.0
    var orderChance: Float = 0.4 {
        didSet {
            orderChance = clampf(orderChance, 0.2, 0.8)
        }
    }
    
    var moveDistance: Double = 14.0
    var drinkOrder: String = ""
    var orderSpriteNode: CCNode!

    class func customerWithOrder(order: String) -> Customer {
        let customer = CCBReader.load("Customer") as! Customer
        let sprite = CCBReader.load("Entity/\(order)") as! CCSprite
        sprite.scale = 0.7
        customer.zOrder = CUSTOMER_DRAW_ORDER
        customer.drinkOrder = order
        customer.orderSpriteNode.addChild(sprite)
        return customer
    }

    override func onEnter() {
        super.onEnter()
        actionDelay = Double(CCRANDOM_0_1() + 0.5)
        setChance()
        
        //CCActionEaseIn(action: CCActionMoveBy(duration: 1.0, position: ccp(0,0)), rate: 1.0)
    }
    
    override func update(dt: CCTime) {
        timeWaiting += dt
        
        switch state {
        case .Idle:
            if (timeWaiting > actionDelay) {
                timeWaiting = 0
                if CCRANDOM_0_1() > orderChance {
                    orderChance += 0.05
                    move()
                } else {
                    order()
                }
            }
        case .Moving:
            if (self.boundingBox().contains(Bar.gameEndPoint)) {
                //println("left the scene!")
                //self.removeFromParent()
                NSNotificationCenter.defaultCenter().postNotificationName(GAMEOVER, object: self)
            }
        case .Ordering, .Spawning:
            timeWaiting = 0.0
        case .Drinking:
            if (timeWaiting > actionDelay) {
                drink()
            }
        case .Angry:
            if (timeWaiting > actionDelay/2) {
                timeWaiting = 0
                if CCRANDOM_0_1() > orderChance {
                    move()
                    orderChance += 0.1
                } else {
                    order()
                }
            }
        }
    }
    
    func move() {
        state = .Moving
        let distance = CGPointMake(CGFloat(moveDistance + Double(10.0 * CCRANDOM_0_1())), CGFloat(0.0))
        let move = CCActionMoveBy(duration: 0.1, position: distance)
        let finishedMove = CCActionCallFunc(target: self, selector: Selector("actionFinished"))
        let moveSequence = CCActionSequence(array: [move, finishedMove])
        self.runAction(moveSequence)
    }
    
    func order() {
        animationManager.runAnimationsForSequenceNamed("ShowOrder")
        orderChance -= 0.3
        state = .Ordering
    }
    
    func drink() {
        //TODO: Missing timeline - Drink
        animationManager.runAnimationsForSequenceNamed("ShowDrink")
        state = .Drinking
    }
    
    func actionFinished() {
        switch state {
        case .Moving:
            if ccpDistance(self.positionInPoints, Bar.gameEndPoint) < 70 {
                println("closing in!")
                moveDistance = 0
                state = .Angry
            } else {
                state = .Idle
            }
            setChance()
        case .Ordering:
            state = .Idle
        case .Drinking:
            if CCRANDOM_0_1() > 0.5 {
                //TODO: Missing timeline - Finish
                animationManager.runAnimationsForSequenceNamed("ShowFinish")
            }
        case .Idle:
            //do nothing
            animationManager.runAnimationsForSequenceNamed("ShowIdle")
        case .Angry:
            //do nothing, angrily
            //TODO: Missing timeline - Angry
            animationManager.runAnimationsForSequenceNamed("ShowAngry")
        case .Spawning:
            order()
        }
    }
    
    func setChance() {
        var score = Gameplay.unsafeScore
        if score < 30 {
            orderChance = 0.6
        } else if score < 60 {
            orderChance = 0.5
        } else if score < 90 {
            orderChance = 0.4
        } else {
            orderChance = 0.3
        }
    }
}
