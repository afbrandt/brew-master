//
//  Tile.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

let MATCH: String = "Match Cleared"
let TILE_CLEAR_TIME = 0.25

let TILE_NORMAL_ZORDER = 15
let TILE_TOUCH_ZORDER = 30

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
        tile.cascadeOpacityEnabled = true
        tile.opacity = 1.0
        //tile._background.color = CCColor.whiteColor()
        return tile
    }
    
    func remove() {
        var grow = CCActionScaleBy(duration: TILE_CLEAR_TIME, scale: 1.2)
        var fade = CCActionFadeOut(duration: TILE_CLEAR_TIME)
        var combo = CCActionSpawn(array: [grow, fade])
        var remove = CCActionRemove()
        var tileAction = CCActionSequence(array: [combo, remove])
        zOrder = 100
        runAction(tileAction)
    }
}

func ==(a: Tile, b: Tile) -> Bool {
        return a.gridCoordinate.row == b.gridCoordinate.row && a.gridCoordinate.column == b.gridCoordinate.column
}
