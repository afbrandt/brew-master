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
        let tempCoordinate = touchTile.gridCoordinate
        touchTile.gridCoordinate = tile.gridCoordinate
        tile.gridCoordinate = tempCoordinate
        //swap array location
        tiles[tile.gridCoordinate.column][tile.gridCoordinate.row] = tile
        tiles[touchTile.gridCoordinate.column][touchTile.gridCoordinate.row] = touchTile
        self.animateTileSwap(touchTile, second: tile)
        //self.scheduleOnce(Selector("checkMatch"), delay: 0.3)
        //self.checkMatch()
        touchTile = Tile.dummyTile()
    }
    
    func settleTiles() {
        var longestSettle: Double = 0.0
        for column in 0..<GRID_SIZE {
            for row in 0..<GRID_SIZE {
                if tiles[column][row] == nil {
                    //returns length of drop
                    let time: Double = self.dropTileAbove(GridCoordinate(row:row, column:column))
                    if time > longestSettle {
                        longestSettle = time
                    }
                }
            }
        }
        
        if longestSettle > 0.0 {
            let delay = CCActionDelay(duration: longestSettle)
            let chainCall = CCActionCallBlock(block: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(SETTLED, object: nil)
            })
            let sequence = CCActionSequence(array: [delay, chainCall])
            runAction(sequence)
        }
        
    }
    
    func dropTileAbove(coord: GridCoordinate) -> Double {
        let tileAbove = self.availableTileAbove(coord)
        //replace array index of tile's original location
        if !tileAbove.isNewTile {
            tiles[tileAbove.gridCoordinate.column][tileAbove.gridCoordinate.row] = nil
        } else {
            tileAbove.isNewTile = false
        }
        //update tile to drop
        if tileAbove.gridCoordinate.isValid() {
            tiles[tileAbove.gridCoordinate.column][tileAbove.gridCoordinate.row] = nil
        }
        tileAbove.gridCoordinate = coord
        tiles[tileAbove.gridCoordinate.column][tileAbove.gridCoordinate.row] = tileAbove
        return self.animateTile(tileAbove, toGridCoordinate: tileAbove.gridCoordinate, notify: false)
    }
    
    func availableTileAbove(coord: GridCoordinate) -> Tile {
        //generate new tile if outside of bounds
        if coord.column >= GRID_SIZE-1 {
            let newTile = Tile.tileFromString(gameState.randomDrink())
            newTile.gridCoordinate = coord
            let columnSpawn = 7+spawnedTiles[coord.row]
            spawnedTiles[coord.row]++
            let tileSpawnPosition = self.pointFromGridCoordinate(GridCoordinate(row: coord.row, column: columnSpawn))
            //newTile.position = self.pointFromGridCoordinate(coord)
            newTile.position = tileSpawnPosition
            newTile.zOrder = TILE_NORMAL_ZORDER
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
    
    func finishedMove() {
        NSNotificationCenter.defaultCenter().postNotificationName(MOVED, object: nil)
    }
    
    func slideRowColumnTile(tile: Tile, byVector vector: CGPoint, forMode mode: SlideMode, animated: Bool) {
        var slideTiles: [Tile] = []
        let row = tile.gridCoordinate.row
        let column = tile.gridCoordinate.column

        var tilesNeeded = 0
        var rowColumnOffset = 0
        var isModeVectorPositive = false
        switch mode {
        case .Horizontal:
            tilesNeeded = abs(Int(vector.y/touchTile.contentSize.height)) + 1
            if vector.y > 0 {
                isModeVectorPositive = true
            }
            rowColumnOffset = row
        case .Vertical:
            tilesNeeded = abs(Int(vector.x/touchTile.contentSize.width)) + 1
            if vector.x > 0 {
                isModeVectorPositive = true
            }
            rowColumnOffset = column
        case .Unknown: break
        }
//        print("need \(tilesNeeded) tiles")
        
        while tilesNeeded > spareSlideTiles.count {
            var spareDrink = ""
            
//            let newSpareTile = Tile.tileFromString("Beer")
            
            var spareOffset = GRID_SIZE-1
            var offset = 0
            var insertMult = -1
            if !isModeVectorPositive {
                offset = GRID_SIZE - 1
                insertMult = 1
                spareOffset = 0
            }
            
            let spareLoc = (spareOffset+insertMult*spareSlideTiles.count + GRID_SIZE) % GRID_SIZE
                        
            var newGridCoordinate =  GridCoordinate(row: insertMult*(spareSlideTiles.count+1) + offset, column: rowColumnOffset)
            spareDrink = tiles[rowColumnOffset][spareLoc]!.contents
            if mode == .Horizontal {
                newGridCoordinate = GridCoordinate(row: rowColumnOffset, column: insertMult*(spareSlideTiles.count+1) + offset)
                spareDrink = tiles[spareLoc][rowColumnOffset]!.contents
            }
            
            let newSpareTile = Tile.tileFromString(spareDrink)
            newSpareTile.gridCoordinate = newGridCoordinate
            addChild(newSpareTile)
            spareSlideTiles.append(newSpareTile)
            newSpareTile.position = pointFromGridCoordinate(newSpareTile.gridCoordinate)
        }
        
        if (vector.x != 0.0) || mode == .Vertical {
            
            for i in 0..<GRID_SIZE {
                if let tile = tiles[column][i] {
                    slideTiles.append(tile)
                }
            }
        } else if (vector.y != 0.0) || mode == .Horizontal {
            for j in 0..<GRID_SIZE {
                if let tile = tiles[j][row] {
                    slideTiles.append(tile)
                }
            }
        }
        
        slideTiles.appendContentsOf(spareSlideTiles)
        
        //animated slide implies end of user move, either return to start or lock in match
        if animated {
            for tile in slideTiles {
                let slideAction = CCActionMoveTo(duration: 0.2, position: ccpAdd(pointFromGridCoordinate(tile.gridCoordinate), vector))
                tile.runAction(slideAction)
            }
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.23 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue(), { 
                self.cleanupSlideTiles(slideTiles)
            })
            
        } else {
            for tile in slideTiles {
                slideTile(tile, byVector: vector, animated: animated)
            }
        }
        
    }
    
    func moveRowColumnTile(tile: Tile, byVector vector: CGPoint, inDirection direction: SlideDirection, animated: Bool) {
        var moveTiles: [Tile] = []
        let row = tile.gridCoordinate.row
        let column = tile.gridCoordinate.column
        let tilePadding: CGFloat = 12.0
        switch direction {
        case .Up:
            let tilesNeeded = abs(Int((vector.y+tilePadding)/touchTile.contentSize.height))+1
            moveTiles = spareDirectedSlideTiles[direction.rawValue]
            while tilesNeeded > spareDirectedSlideTiles[direction.rawValue].count {
                let spareLoc = (2 * GRID_SIZE - moveTiles.count - 1) % GRID_SIZE
                let newCoordinate = GridCoordinate(row: row, column: moveTiles.count * -1 - 1)
                if let spareTile = tiles[spareLoc][row] {
                    let spareDrink = spareTile.contents
                    let newSpareTile = Tile.tileFromString(spareDrink)
                    newSpareTile.gridCoordinate = newCoordinate
                    addChild(newSpareTile)
                    spareDirectedSlideTiles[direction.rawValue].append(newSpareTile)
                    newSpareTile.position = pointFromGridCoordinate(newSpareTile.gridCoordinate)
                    moveTiles.append(tile)
                }
            }
            for j in 0..<GRID_SIZE {
                if let tile = tiles[j][row] {
                    moveTiles.append(tile)
                }
            }
        case .Down:
            let tilesNeeded = abs(Int((vector.y-tilePadding)/touchTile.contentSize.height))+1
            moveTiles = spareDirectedSlideTiles[direction.rawValue]
            while tilesNeeded > spareDirectedSlideTiles[direction.rawValue].count {
                let spareLoc = moveTiles.count % GRID_SIZE
                let newCoordinate = GridCoordinate(row: row, column: GRID_SIZE + moveTiles.count)
                if let spareTile = tiles[spareLoc][row] {
                    let spareDrink = spareTile.contents
                    let newSpareTile = Tile.tileFromString(spareDrink)
                    newSpareTile.gridCoordinate = newCoordinate
                    addChild(newSpareTile)
                    spareDirectedSlideTiles[direction.rawValue].append(newSpareTile)
                    newSpareTile.position = pointFromGridCoordinate(newSpareTile.gridCoordinate)
                    moveTiles.append(tile)
                }
            }
            for j in 0..<GRID_SIZE {
                if let tile = tiles[j][row] {
                    moveTiles.append(tile)
                }
            }
        case .Left:
            let tilesNeeded = abs(Int((vector.x-tilePadding)/touchTile.contentSize.height))+2
            moveTiles = spareDirectedSlideTiles[direction.rawValue]
            while tilesNeeded > spareDirectedSlideTiles[direction.rawValue].count {
                let spareLoc = moveTiles.count % GRID_SIZE
                let newCoordinate = GridCoordinate(row: GRID_SIZE + moveTiles.count, column: column)
                if let spareTile = tiles[column][spareLoc] {
                    let spareDrink = spareTile.contents
                    let newSpareTile = Tile.tileFromString(spareDrink)
                    newSpareTile.gridCoordinate = newCoordinate
                    addChild(newSpareTile)
                    spareDirectedSlideTiles[direction.rawValue].append(newSpareTile)
                    newSpareTile.position = pointFromGridCoordinate(newSpareTile.gridCoordinate)
                    moveTiles.append(tile)
                    
                }
            }
            for i in 0..<GRID_SIZE {
                if let tile = tiles[column][i] {
                    moveTiles.append(tile)
                }
            }
        case .Right:
            let tilesNeeded = abs(Int((vector.x+tilePadding)/touchTile.contentSize.height))+2
            moveTiles = spareDirectedSlideTiles[direction.rawValue]
            while tilesNeeded > spareDirectedSlideTiles[direction.rawValue].count {
                let spareLoc = (2 * GRID_SIZE - moveTiles.count - 1) % GRID_SIZE
                let newCoordinate = GridCoordinate(row: moveTiles.count * -1 - 1, column: column)
                if let spareTile = tiles[column][spareLoc] {
                    let spareDrink = spareTile.contents
                    let newSpareTile = Tile.tileFromString(spareDrink)
                    newSpareTile.gridCoordinate = newCoordinate
                    addChild(newSpareTile)
                    spareDirectedSlideTiles[direction.rawValue].append(newSpareTile)
                    newSpareTile.position = pointFromGridCoordinate(newSpareTile.gridCoordinate)
                    moveTiles.append(tile)
                }
            }
            for i in 0..<GRID_SIZE {
                if let tile = tiles[column][i] {
                    moveTiles.append(tile)
                }
            }
        default: break
        }
        
        //animated move implies end of user move, either return to start or lock in match
        if animated {
            for tile in moveTiles {
                let slideAction = CCActionMoveTo(duration: 0.2, position: ccpAdd(pointFromGridCoordinate(tile.gridCoordinate), vector))
                if tile.numberOfRunningActions() > 0 {
                    tile.stopAllActions()
                }
                tile.runAction(slideAction)
            }
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.23 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue(), { 
                self.cleanupSlideTiles(moveTiles)
            })
            
        } else {
            for tile in moveTiles {
                slideTile(tile, byVector: vector, animated: animated)
            }
        }
    }
    
    func cleanupSlideTiles(slideTiles: [Tile]) {
        for i in 0..<spareDirectedSlideTiles.count {
            for tile in spareDirectedSlideTiles[i] {
                if !slideTiles.contains(tile) {
                    tile.removeFromParent()
                }
            }
            spareDirectedSlideTiles[i] = []
        }
        
        for tile in slideTiles {
            if tile.position.x > 0.0 && tile.position.x < contentSize.width &&
                tile.position.y > 0.0 && tile.position.y < contentSize.height {

                let tileCoordinate = gridCoordinateFromPoint(tile.position)
                tile.gridCoordinate = tileCoordinate
                tiles[tileCoordinate.column][tileCoordinate.row] = tile
                
            } else {
                spareSlideTiles.append(tile)
            }
        }
        
        for tile in self.spareSlideTiles {
            tile.removeFromParent()
        }
        self.spareSlideTiles.removeAll()
        self.state = .Matching
        finishedMove()
    }
    
    func slideTile(tile: Tile, byVector vector: CGPoint, animated: Bool) {
        tile.position = ccpAdd(pointFromGridCoordinate(tile.gridCoordinate), vector)
    }
}