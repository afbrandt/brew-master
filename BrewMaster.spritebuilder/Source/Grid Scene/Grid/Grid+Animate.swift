//
//  Grid+Animate.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/5/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

extension Grid {

    func animateTile(tile: Tile, toGridCoordinate coord: GridCoordinate, notify: Bool) -> Double {
        let endPosition = self.pointFromGridCoordinate(coord)
        //var startPosition = ccpAdd(endPosition, ccp(0,300))
        //tile.position = startPosition
        var coordDiff = abs((tile.position.y - endPosition.y) / columnHeight)
        var actionDuration = CCTime(0.06 * (coordDiff + 1))
        let action = CCActionMoveTo(duration: actionDuration, position: endPosition)
        var arr: [CCActionFiniteTime] = []
        
        arr.append(action)
        
        if notify {
            let notice = CCActionCallBlock(block: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(MOVED, object: nil)
            })
            //arr.append(notice)
        }
        
        let sequence = CCActionSequence(array: arr)
        
        //tile.runAction(CCActionSequence(array: [action, block]))
        //println("number of actions:\(tile.numberOfRunningActions())")
        //println("coord diff:\(coordDiff)")
        if tile.numberOfRunningActions() == 0 {
            tile.runAction(sequence)
        } else {
            tile.stopAllActions()
            tile.runAction(sequence)
        }
        
        return actionDuration
    }
    
    func animateTileSwap(first: Tile, second: Tile) {
        self.animateTile(first, toGridCoordinate: first.gridCoordinate, notify: true)
        self.animateTile(second, toGridCoordinate: second.gridCoordinate, notify: false)
    }
}