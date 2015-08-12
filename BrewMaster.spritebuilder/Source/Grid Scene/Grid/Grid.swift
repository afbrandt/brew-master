//
//  Grid.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

let MOVED = "Moved tiles..."
let FINISHED = "Finished clearing tiles!"

struct GridCoordinate {
    var row: Int = 0
    var column: Int = 0
    
    func isValid() -> Bool {
        if row == -1 || column == -1 || row >= 7 || column >= 7 {
            return false
        } else {
            return true
        }
    }
}

//MARK: - Main class, lifecycle related methods
class Grid: CCNode {

    var tiles: [[Tile?]] = [[Tile?]](count: 7, repeatedValue: [Tile?](count: 7, repeatedValue: Tile?()))
    var spawnedTiles: [Int] = [Int](count: 7, repeatedValue: 0)
    var state: GameState!
    var columnWidth: CGFloat = 0
    var columnHeight: CGFloat = 0
    var tileMarginVertical: CGFloat = 0
    var tileMarginHorizontal: CGFloat = 0
    //Grid+Touch
    var touchTile: Tile!
    var currentCoordinate: GridCoordinate = GridCoordinate(row: 0, column: 0)
    var tileOffset: CGPoint = ccp(0, 0)
    //Grid+Match
    var matches: [Match] = [Match]()
    var matched: Set<Tile> = []
    var needsCheck: Bool = false
    
    let GRID_SIZE: Int = 7
    
    func didLoadFromCCB() {
        state = GameState.sharedInstance
        self.setupGrid()
        self.userInteractionEnabled = true
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserver(self, selector: Selector("settleTiles"), name: FINISHED, object: nil)
        center.addObserver(self, selector: Selector("clearMatch"), name: CLEARED, object: nil)
        
        center.addObserver(self, selector: Selector("checkMatch"), name: MOVED, object: nil)
        center.addObserver(self, selector: Selector("checkMatch"), name: SETTLED, object: nil)
    }
    
    override func onExit() {
        super.onExit()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupGrid() {
        var tile = CCBReader.load("Tile")
        columnWidth = tile.contentSize.width
        columnHeight = tile.contentSize.height
        tileMarginHorizontal = (self.contentSize.width - (CGFloat(GRID_SIZE) * columnWidth)) / (CGFloat(GRID_SIZE)+1)
        tileMarginVertical = (self.contentSize.height - (CGFloat(GRID_SIZE) * columnHeight)) / (CGFloat(GRID_SIZE)+1)
    }
    
    func addTileToGrid(tile: Tile, atColumn column: Int, atRow row: Int) {
        var coord = GridCoordinate(row: row, column: column)
        self.addTileToGrid(tile, atGridCoordinate: coord)
    }
    
    func addTileToGrid(tile: Tile, atGridCoordinate coordinate: GridCoordinate) {
        tiles[coordinate.column][coordinate.row] = tile
        self.addChild(tile)
        var spawnCoordinate = GridCoordinate(row: coordinate.row, column: 8)
        tile.position = self.pointFromGridCoordinate(spawnCoordinate)
        tile.gridCoordinate = coordinate
        self.animateTile(tile, toGridCoordinate: coordinate, notify: false)
    }
    
}