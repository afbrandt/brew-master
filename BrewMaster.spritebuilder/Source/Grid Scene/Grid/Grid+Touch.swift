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
        if self.state == .Idle {
            let loc = touch.locationInNode(self) as CGPoint
            let coord = self.gridCoordinateFromPoint(loc) as GridCoordinate
            touchCoordinate = loc
            tileOffset = ccpSub(pointFromGridCoordinate(coord), loc)
            currentCoordinate = coord
            touchTile = tiles[coord.column][coord.row]
            touchTile.zOrder = TILE_TOUCH_ZORDER
            //println("touch detected at column: \(coord.column) and row: \(coord.row)")
            self.state = .Moving
            self.slideDirection = .Unknown
        }
    }
    
    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if self.state == .Moving {
            let loc = touch.locationInNode(self) as CGPoint

            //This implementations adds a sliding motion to the tiles
            let touchDiff = ccpSub(loc, touchCoordinate)
            let xVect = abs(touchDiff.x)
            let yVect = abs(touchDiff.y)
            let diff = yVect - xVect
            var slide: CGPoint = ccp(0,0)
            
            if diff > 0.0 {
                var slideY = diff
                if touchDiff.y < 0 {
                    slideY *= -1.0
                    slideDirection = .Down
                } else {
                    slideDirection = .Up
                }
                slide = ccp(0, slideY)
//                slideMode = .Horizontal
            } else {
                var slideX = diff
                if touchDiff.x > 0 {
                    slideX *= -1.0
                    slideDirection = .Right
                } else {
                    slideDirection = .Left
                }
                slide = ccp(slideX, 0)
//                slideMode = .Vertical
            }
            
            moveRowColumnTile(touchTile, byVector: slide, inDirection: slideDirection, animated: false)
        }
    }
    
    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if self.state == .Moving {
            let loc = touch.locationInNode(self) as CGPoint
            let newPosition = loc
            let oldPosition = self.pointFromGridCoordinate(touchTile.gridCoordinate)
            var newPositionVector = ccpSub(newPosition, oldPosition)
            
            let xVect = abs(newPositionVector.x)
            let yVect = abs(newPositionVector.y)
            var diff = yVect - xVect
            
            if slideMode == .Horizontal {
                if newPositionVector.y < 0 {
                    diff *= -1.0
                }
                newPositionVector = ccp(0, diff)
            } else if slideMode == .Vertical {
                if newPositionVector.x > 0 {
                    diff *= -1.0
                }
                newPositionVector = ccp(diff, 0)
            }
            
            state = .Adjusting
        }
    }
    
    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
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
        let x = columnHeight * (CGFloat(coord.row) + 0.5) + tileMarginHorizontal * CGFloat(coord.row + 1)
        let y = columnWidth * (CGFloat(coord.column) + 0.5) + tileMarginVertical * CGFloat(coord.column + 1)
        return CGPoint(x: x, y: y)
    }
    
}