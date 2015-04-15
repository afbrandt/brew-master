//
//  Gameplay.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

class Gameplay: CCNode {
    
    //code connected elements
    var _grid: Grid!
    var _gridContainer: CCClippingNode!
    var _gridStencil: CCNode!
    
    //programmatic elements
    var state: GameState!
    
    func didLoadFromCCB() {
        state = GameState.sharedInstance
        _gridContainer.stencil = _gridStencil
        _gridContainer.alphaThreshold = 0.0
        self.generateGrid()
    }
    
    func generateGrid() {
        for var column=0; column<7; column++ {
            for var row=0; row<7; row++ {
                var delay = CCTime(column*row/49)
                
                var ingredient = state.randomAvailableIngredient()
                var tile = Tile.tileFromIngredient(ingredient)
                tile.isNewTile = false
                _grid.addTileToGrid(tile, atColumn: column, atRow: row)
                //self.scheduleBlock(^{}, delay: delay)
            }
        }
    }
    

}
