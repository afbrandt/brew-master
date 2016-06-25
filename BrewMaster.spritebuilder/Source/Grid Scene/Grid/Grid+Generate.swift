//
//  Grid+Generate.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 8/12/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

extension Grid {

    // Brute force generation of grid using validRandomOrderForCoordinate() to pick order string
    // End result is OK, no pairs together though.
    func setupNormalGrid() {
        for var column = 0; column < GRID_SIZE; column++ {
            for var row = 0; row < GRID_SIZE; row++ {
                let coord = GridCoordinate(row: row, column: column)
                let order = validRandomOrderForCoordinate(coord)
                let tile = Tile.tileFromString(order)
                addChild(tile)
                tile.gridCoordinate = coord
                tile.isNewTile = false
                tile.position = pointFromGridCoordinate(coord)
                tiles[coord.column][coord.row] = tile
//                addTileToGrid(tile, atGridCoordinate: coord)
            }
        }
        //settleTiles()
    }
    
    // Visits each neighbor tile and ensures order does not match
    func validRandomOrderForCoordinate(coordinate: GridCoordinate) -> String {
    
        var possibleOrders = gameState.currentDrinkTypes
        let above = GridCoordinate(row: coordinate.row+1, column: coordinate.column)
        let below = GridCoordinate(row: coordinate.row-1, column: coordinate.column)
        let left = GridCoordinate(row: coordinate.row, column: coordinate.column-1)
        let right = GridCoordinate(row: coordinate.row, column: coordinate.column+1)
        
        if above.isValid() {
            if let tile = tiles[above.column][above.row] {
                let order = tile.contents
                if let index = possibleOrders.indexOf(order) {
                    possibleOrders.removeAtIndex(index)
                }
            }
        }
        
        if below.isValid() {
            if let tile = tiles[below.column][below.row] {
                let order = tile.contents
                if let index = possibleOrders.indexOf(order) {
                    possibleOrders.removeAtIndex(index)
                }
            }
        }
        
        if left.isValid() {
            if let tile = tiles[left.column][left.row] {
                let order = tile.contents
                if let index = possibleOrders.indexOf(order) {
                    possibleOrders.removeAtIndex(index)
                }
            }
        }
        
        if right.isValid() {
            if let tile = tiles[right.column][right.row] {
                let order = tile.contents
                if let index = possibleOrders.indexOf(order) {
                    possibleOrders.removeAtIndex(index)
                }
            }
        }
        
        //randomly pick from remaining order types
        let index = Int(CCRANDOM_0_1() * Float(possibleOrders.count))
        let order = possibleOrders[index]
        return order
    }
    
}