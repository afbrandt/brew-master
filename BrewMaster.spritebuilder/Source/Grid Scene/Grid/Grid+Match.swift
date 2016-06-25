//
//  Grid+Match.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/8/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

enum MatchPriority {
    case Regular, Large, Super
}

extension Grid {

    func checkMatch() {
        touchTile = Tile.dummyTile()
        if self.hasMatch() {
            self.clearMatch()
//            self.settleTiles()
//            matches.removeAll(keepCapacity: false)
            matched.removeAll(keepCapacity: false)
            spawnedTiles = [Int](count: 7, repeatedValue:0)
//            var delay = CCActionDelay(duration: 0.5)
//            var function = CCActionCallFunc(target: self, selector: Selector("checkMatch"))
//            self.runAction(CCActionSequence(array: [delay, function]))
        } else {
            self.userInteractionEnabled = true
            self.state = .Idle
        }
    }
    
    func checkRowColumn() {
        let startCoord = touchTile.gridCoordinate
        let slideCoord = gridCoordinateFromPoint(touchTile.position)
        var potentialMatch = false
        
//        switch slideMode {
//        case .Vertical:
//            print("checking vertical")
        switch slideDirection {
        case .Left, .Right:
            let slideOffset = startCoord.row - slideCoord.row
            for i in 0..<GRID_SIZE {
                let computedRow = (i + slideOffset + GRID_SIZE) % GRID_SIZE
                
                guard let checkTile = tiles[startCoord.column][computedRow] else {
                    return
                }
                
                var aboveOneMatches = false
                let aboveOneCoordinate = GridCoordinate(row: i, column: startCoord.column+1)
                if aboveOneCoordinate.isValid() {
                    if let aboveTile = tiles[aboveOneCoordinate.column][aboveOneCoordinate.row] where aboveTile.contents == checkTile.contents {
                        aboveOneMatches = true
                    }
                }
                
                var aboveTwoMatches = false
                let aboveTwoCoordinate = GridCoordinate(row: i, column: startCoord.column+2)
                if aboveTwoCoordinate.isValid() {
                    if let aboveTile = tiles[aboveTwoCoordinate.column][aboveTwoCoordinate.row] where aboveTile.contents == checkTile.contents {
                        aboveTwoMatches = true
                    }
                }
                
                var belowOneMatches = false
                let belowOneCoordinate = GridCoordinate(row: i, column: startCoord.column-1)
                if belowOneCoordinate.isValid() {
                    if let belowTile = tiles[belowOneCoordinate.column][belowOneCoordinate.row] where belowTile.contents == checkTile.contents {
                        belowOneMatches = true
                    }
                }
                
                var belowTwoMatches = false
                let belowTwoCoordinate = GridCoordinate(row: i, column: startCoord.column-2)
                if belowTwoCoordinate.isValid() {
                    if let belowTile = tiles[belowTwoCoordinate.column][belowTwoCoordinate.row] where belowTile.contents == checkTile.contents {
                        belowTwoMatches = true
                    }
                }
                
                if (aboveOneMatches && aboveTwoMatches) || (aboveOneMatches && belowOneMatches) || (belowOneMatches && belowTwoMatches) {
//                    print("matched \(checkTile.contents)")
                    potentialMatch = true
                }
            }
//        case .Horizontal:
         case .Up, .Down:
            let slideOffset = startCoord.column - slideCoord.column
            for i in 0..<GRID_SIZE {
                let computedColumn = (i + slideOffset + GRID_SIZE) % GRID_SIZE

                guard let checkTile = tiles[computedColumn][startCoord.row] else {
                    return
                }
                
                var leftOneMatches = false
                let leftOneCoordinate = GridCoordinate(row: startCoord.row-1, column: i)
                if leftOneCoordinate.isValid() {
                    if let leftOneTile = tiles[leftOneCoordinate.column][leftOneCoordinate.row] where leftOneTile.contents == checkTile.contents {
                        leftOneMatches = true
                    }
                }
                
                var leftTwoMatches = false
                let leftTwoCoordinate = GridCoordinate(row: startCoord.row-2, column: i)
                if leftTwoCoordinate.isValid() {
                    if let leftTwoTile = tiles[leftTwoCoordinate.column][leftTwoCoordinate.row] where leftTwoTile.contents == checkTile.contents {
                        leftTwoMatches = true
                    }
                }
                
                var rightOneMatches = false
                let rightOneCoordinate = GridCoordinate(row: startCoord.row+1, column: i)
                if rightOneCoordinate.isValid() {
                    if let rightOneTile = tiles[rightOneCoordinate.column][rightOneCoordinate.row] where rightOneTile.contents == checkTile.contents {
                        rightOneMatches = true
                    }
                }
                
                var rightTwoMatches = false
                let rightTwoCoordinate = GridCoordinate(row: startCoord.row+2, column: i)
                if rightTwoCoordinate.isValid() {
                    if let rightTwoTile = tiles[rightTwoCoordinate.column][rightTwoCoordinate.row] where rightTwoTile.contents == checkTile.contents {
                        rightTwoMatches = true
                    }
                }
                
                if (rightOneMatches && rightTwoMatches) || (rightOneMatches && leftOneMatches) || (leftOneMatches && leftTwoMatches) {
//                    print("matched \(checkTile.contents)")
                    potentialMatch = true
                }
            }
        case .Unknown: break
        }
        
        hasPotentialMatch = potentialMatch
    }

    func hasMatch() -> Bool {
        var foundMatches: [Match] = []
        //Horizontal Matching
        for row in 0..<GRID_SIZE-2 {
            for column in 0..<GRID_SIZE {
                if let tile1 = tiles[column][row], let tile2 = tiles[column][row+1], let tile3 = tiles[column][row+2] {
                    if tile1.contents == tile2.contents && tile1.contents == tile3.contents {
                        let newMatch = Match(tiles: [tile1, tile2, tile3], type:tile1.contents)
                        foundMatches.append(newMatch)
                        //println("Match found!")
                    }
                }
            }
        }
        //Vertical Matching
        for column in 0..<GRID_SIZE-2 {
            for row in 0..<GRID_SIZE {
                if let tile1 = tiles[column][row], let tile2 = tiles[column+1][row], let tile3 = tiles[column+2][row] {
                    if tile1.contents == tile2.contents && tile1.contents == tile3.contents {
                        let newMatch = Match(tiles: [tile1, tile2, tile3], type:tile1.contents)
                        foundMatches.append(newMatch)
                    }
                }
            }
        }
        //println("Finished check!")
        return mergeMatches(foundMatches)
    }
    
    func mergeMatches(matches: [Match]) -> Bool {
        var mergedMatches: [Match] = []
        var merged: [Bool] = [Bool](count: matches.count, repeatedValue: false)
        
        for i in 0..<matches.count {
            if !merged[i] {
                var match = matches[i]
                for j in i+1..<matches.count {
                    if !merged[j] {
                        let possibleMergeMatch = matches[j]
                        if match.tiles.intersect(possibleMergeMatch.tiles).count > 0 {
                            match.appendTiles(possibleMergeMatch)
                            merged[j] = true
                        }
                    }
                }
                mergedMatches.append(match)
                merged[i] = true
            }
        }
        self.matches = mergedMatches
        
        return !mergedMatches.isEmpty
    }
    
    func clearMatch() {
        var clearActions: [CCActionFiniteTime] = []
        //for match in matches {
        if !matches.isEmpty {
            let match = matches.removeLast()
            var type: String = ""
            var spawnArr: [CCActionFiniteTime] = []
            for tile in match.tiles {
                //tile._background.color = CCColor(red: 0, green: 0, blue: 0, alpha: 1)
                //self.dropTileAbove(tile)
                type = tile.contents
                
                //do more than just remove, gotta a-ni-mate
//                var block = CCActionCallBlock(block: { () -> Void in
//                    tile.remove()
//                })
                let block = CCActionCallFunc(target: tile, selector: Selector("remove"))
                //clearActions.append(block)
                spawnArr.append(block)
                //tile.removeFromParent()
                tiles[tile.gridCoordinate.column][tile.gridCoordinate.row] = nil
            }
            let spawnSequence = CCActionSpawn(array: spawnArr)
            clearActions.append(spawnSequence)
            let delay = CCActionDelay(duration: TILE_CLEAR_TIME)
            clearActions.append(delay)
            if match.tiles.count == 3 {
                NSNotificationCenter.defaultCenter().postNotificationName(MATCH, object: type)
            } else if match.tiles.count == 4 {
                NSNotificationCenter.defaultCenter().postNotificationName(LARGE_MATCH, object: type)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(SUPER_MATCH, object: type)
            }
        }
        
        if !clearActions.isEmpty {
            let notify = CCActionCallBlock(block: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName(CLEARED, object: nil)
            })
            clearActions.append(notify)
            let sequence = CCActionSequence(array: clearActions)
            runAction(sequence)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(FINISHED, object: nil)
            self.userInteractionEnabled = true
        }
    }
    
}