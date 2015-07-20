//
//  Tile.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

let MATCH: String = "Match Cleared"

struct Match {
    var tiles: Set<Tile>
    var type: String
    
    func containsTile(tile: Tile) -> Bool {
        return tiles.contains(tile)
    }
    
    mutating func appendTiles(newTiles: Match) {
        //var set: Set<Tile> = Set(newTiles)
        self.tiles.unionInPlace(newTiles.tiles)
    }
}

class Tile: CCNode {
    
    var _background: CCNodeColor!
    var _sprite: CCSprite!
    
    var gridCoordinate: GridCoordinate!
    var contents: String!
    var isNewTile: Bool = true
    
    class func dummyTile() -> Tile {
        let tile = CCBReader.load("Tile") as! Tile
        tile.gridCoordinate = GridCoordinate(row: -1, column: -1)
        tile.contents = ""
        //tile._background.color = CCColor.whiteColor()
        return tile
    }
}

func ==(a: Tile, b: Tile) -> Bool {
        return a.gridCoordinate.row == b.gridCoordinate.row && a.gridCoordinate.column == b.gridCoordinate.column
}
