//
//  Grid+Animate.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/5/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

extension Grid {

    func animateTile(tile: Tile, toGridCoordinate coord: GridCoordinate) {
        let endPosition = self.pointFromGridCoordinate(coord)
        //var startPosition = ccpAdd(endPosition, ccp(0,300))
        //tile.position = startPosition
        var coordDiff = abs((tile.position.y - endPosition.y) / columnHeight)
        var actionDuration = CCTime(0.06 * (coordDiff + 1))
        let action = CCActionMoveTo(duration: actionDuration, position: endPosition)
        //tile.runAction(CCActionSequence(array: [action, block]))
        //println("number of actions:\(tile.numberOfRunningActions())")
        //println("coord diff:\(coordDiff)")
        if tile.numberOfRunningActions() == 0 {
            tile.runAction(action)
        } else {
            tile.stopAllActions()
            tile.runAction(action)
        }
    }
    
    func animateTileSwap(first: Tile, second: Tile) {
        self.animateTile(first, toGridCoordinate: first.gridCoordinate)
        self.animateTile(second, toGridCoordinate: second.gridCoordinate)
    }
}