//
//  Grid+Move.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/11/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

extension Grid {

    func swapTouchTileWithTile(tile: Tile) {
        self.userInteractionEnabled = false
        //swap grid coordinates
        var tempCoordinate = touchTile.gridCoordinate
        touchTile.gridCoordinate = tile.gridCoordinate
        tile.gridCoordinate = tempCoordinate
        //swap array location
        tiles[tile.gridCoordinate.column][tile.gridCoordinate.row] = tile
        tiles[touchTile.gridCoordinate.column][touchTile.gridCoordinate.row] = touchTile
        self.animateTileSwap(touchTile, second: tile)
        self.scheduleOnce(Selector("checkMatch"), delay: 0.3)
        //self.checkMatch()
        touchTile = Tile.dummyTile()
    }
    
    func settleTiles() {
        for var column = 0; column < GRID_SIZE; column++ {
            for var row = 0; row < GRID_SIZE; row++ {
                if tiles[column][row] == nil {
                    self.dropTileAbove(GridCoordinate(row:row, column:column))
                }
            }
        }
    }
    
    func dropTileAbove(coord: GridCoordinate) {
        var tileAbove = self.availableTileAbove(coord)
        //replace array index of tile's original location
        if !tileAbove.isNewTile {
            tiles[tileAbove.gridCoordinate.column][tileAbove.gridCoordinate.row] = nil
        } else {
            tileAbove.isNewTile = false
        }
        //update tile to drop
        tileAbove.gridCoordinate = coord
        tiles[tileAbove.gridCoordinate.column][tileAbove.gridCoordinate.row] = tileAbove
        self.animateTile(tileAbove, toGridCoordinate: tileAbove.gridCoordinate)
    }
    
    func availableTileAbove(coord: GridCoordinate) -> Tile {
        //generate new tile if outside of bounds
        if coord.column >= GRID_SIZE-1 {
            var newTile = Tile.tileFromIngredient(state.randomAvailableIngredient())
            newTile.gridCoordinate = coord
            var columnSpawn = 7+spawnedTiles[coord.row]
            spawnedTiles[coord.row]++
            var tileSpawnPosition = self.pointFromGridCoordinate(GridCoordinate(row: coord.row, column: columnSpawn))
            //newTile.position = self.pointFromGridCoordinate(coord)
            newTile.position = tileSpawnPosition
            self.addChild(newTile)
            return newTile
        }
        //check if coordinate is nil
        if let above = tiles[coord.column+1][coord.row] {
            return above
        } else {
            return self.availableTileAbove(GridCoordinate(row: coord.row, column: coord.column+1))
        }
    }
    
    
}