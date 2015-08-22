//
//  Grid+Match.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/8/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

extension Grid {

    func checkMatch() {
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
        }
    }

    func hasMatch() -> Bool {
        //Horizontal Matching
        for var row = 0; row < GRID_SIZE-2; row++ {
            for var column = 0; column < GRID_SIZE; column++ {
                if let tile1 = tiles[column][row], let tile2 = tiles[column][row+1], let tile3 = tiles[column][row+2] {
                    if tile1.contents == tile2.contents && tile1.contents == tile3.contents {
                        var newMatch = Match(tiles: [tile1, tile2, tile3], type:tile1.contents)
                        matched.unionInPlace(newMatch.tiles)
                        var hasMatch = false
                        for var i = 0; i < matches.count; i++ {
                            var match = matches[i]
                            //check to see if the match is larger than 3 tiles
                            if match.tiles.intersect(newMatch.tiles).count > 0 {
                                match.appendTiles(newMatch)
                                matches[i] = match
                                hasMatch = true
                                //println("match size \(match.tiles.count)")
                            }
                        }
                        if !hasMatch {
                            matches.append(newMatch)
                        }
                        //println("Match found!")
                    }
                }
            }
        }
        //Vertical Matching
        for var column = 0; column < GRID_SIZE-2; column++ {
            for var row = 0; row < GRID_SIZE; row++ {
                if let tile1 = tiles[column][row], let tile2 = tiles[column+1][row], let tile3 = tiles[column+2][row] {
                    if tile1.contents == tile2.contents && tile1.contents == tile3.contents {
                        var newMatch = Match(tiles: [tile1, tile2, tile3], type:tile1.contents)
                        matched.unionInPlace(newMatch.tiles)
                        var hasMatch = false
                        for var i = 0; i < matches.count; i++ {
                            var match = matches[i]
                            //check to see if the match is larger than 3 tiles
                            if match.tiles.intersect(newMatch.tiles).count > 0 {
                                match.appendTiles(newMatch)
                                matches[i] = match
                                hasMatch = true
                                //println("match size \(match.tiles.count)")
                            }
                        }
                        if !hasMatch {
                            matches.append(newMatch)
                        }
                        //println("Match found!")
                    }
                }
            }
        }
        //println("Finished check!")
        return !matches.isEmpty
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
                var block = CCActionCallBlock(block: { () -> Void in
                    tile.remove()
                })
                //clearActions.append(block)
                spawnArr.append(block)
                //tile.removeFromParent()
                tiles[tile.gridCoordinate.column][tile.gridCoordinate.row] = nil
            }
            let spawnSequence = CCActionSpawn(array: spawnArr)
            clearActions.append(spawnSequence)
            let delay = CCActionDelay(duration: TILE_CLEAR_TIME)
            clearActions.append(delay)
            NSNotificationCenter.defaultCenter().postNotificationName(MATCH, object: type)
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