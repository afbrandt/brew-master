//
//  Grid+Touch.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/4/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

//MARK: - Touch related extension
extension Grid {
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let loc = touch.locationInNode(self) as CGPoint
        let coord = self.gridCoordinateFromPoint(loc) as GridCoordinate
        touchTile = tiles[coord.column][coord.row]
        //println("touch detected at column: \(coord.column) and row: \(coord.row)")
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let loc = touch.locationInNode(self) as CGPoint
        let coord = self.gridCoordinateFromPoint(loc) as GridCoordinate!
        if touchTile.gridCoordinate.row != -1 && coord.isValid() &&
                (coord.column != touchTile.gridCoordinate.column ||
                coord.row != touchTile.gridCoordinate.row) {
            if let tile = tiles[coord.column][coord.row] {
                self.swapTouchTileWithTile(tile)
            }
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchTile = Tile.dummyTile()
    }
    
    func gridCoordinateFromPoint(point: CGPoint) -> GridCoordinate {
        let x = Int(point.x)
        let y = Int(point.y)
        let height = Int(columnHeight)
        let width = Int(columnWidth)
        
        let rowDiff = x / height as Int
        let row = (x - rowDiff) / height
        let columnDiff = y / width as Int
        let column = (y - columnDiff) / height
        return GridCoordinate(row: row, column: column)
    }
    
    func pointFromGridCoordinate(coord: GridCoordinate) -> CGPoint {
        let x = columnHeight * CGFloat(coord.row) + tileMarginHorizontal * CGFloat(coord.row + 1)
        let y = columnWidth * CGFloat(coord.column) + tileMarginVertical * CGFloat(coord.column + 1)
        return CGPoint(x: x, y: y)
    }
    
}