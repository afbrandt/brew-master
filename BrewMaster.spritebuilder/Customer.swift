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
    case Ordering, Moving, Drinking, Idle, Angry
}

class Customer: CCNode {

    let gameState: GameState = GameState.sharedInstance
    var state: CustomerState = .Idle
    var timeWaiting: Double = 0.0
    var actionDelay: Double = 1.0
    var orderChance: Float = 0.7
    
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

    func didLoadFromCCB() {
        actionDelay = Double(CCRANDOM_0_1() + 0.5)
    }
    
    override func update(dt: CCTime) {
        timeWaiting += dt
        
        switch state {
            case .Idle:
                if (timeWaiting > actionDelay) {
                    timeWaiting = 0
                    if CCRANDOM_0_1() > orderChance {
                        move()
                    } else {
                        orderChance -= 0.02
                        order()
                    }
                }
            case .Moving:
                if (self.boundingBox().contains(Bar.gameEndPoint)) {
                    //println("left the scene!")
                    //self.removeFromParent()
                    NSNotificationCenter.defaultCenter().postNotificationName(GAMEOVER, object: self)
                }
            case .Ordering:
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
                    } else {
                        order()
                        orderChance -= 0.1
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
        state = .Ordering
    }
    
    func drink() {
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
        default:
            println("")
        }
    }
}
