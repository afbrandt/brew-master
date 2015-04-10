//
//  Tile.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

protocol Entity {
    
}

class Tile: CCNode {
    
    var _background: CCNodeColor!
    var _sprite: CCSprite!
    
    var gridCoordinate: GridCoordinate!
    var contents: Entity!
    
    class func dummyTile() -> Tile {
        let tile = Tile()
        tile.gridCoordinate = GridCoordinate(row: -1, column: -1)
        return tile
    }
   
}
