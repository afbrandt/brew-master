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
        let action = CCActionMoveTo(duration: 0.3, position: endPosition)
        tile.runAction(action)
    }
    
    func animateTileSwap(first: Tile, second: Tile) {
        self.animateTile(first, toGridCoordinate: first.gridCoordinate)
        self.animateTile(second, toGridCoordinate: second.gridCoordinate)
    }
}