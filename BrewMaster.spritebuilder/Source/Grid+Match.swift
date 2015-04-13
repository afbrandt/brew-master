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
            self.settleTiles()
            matches.removeAll(keepCapacity: false)
            matched.removeAll(keepCapacity: false)
            var delay = CCActionDelay(duration: 0.2)
            var function = CCActionCallFunc(target: self, selector: Selector("checkMatch"))
            self.runAction(CCActionSequence(array: [delay, function]))
        }
    }

    func hasMatch() -> Bool {
        //Horizontal Matching
        for var row = 0; row < GRID_SIZE-2; row++ {
            for var column = 0; column < GRID_SIZE; column++ {
                if let tile1 = tiles[column][row], let tile2 = tiles[column][row+1], let tile3 = tiles[column][row+2] {
                    if tile1.contents == tile2.contents && tile1.contents == tile3.contents {
                        var newMatch = Match(tiles: [tile1, tile2, tile3])
                        matched.unionInPlace(newMatch.tiles)
                        var hasMatch = false
                        for var i = 0; i < matches.count; i++ {
                            var match = matches[i]
                            //check to see if the match is larger than 3 tiles
                            if match.tiles.intersect(newMatch.tiles).count > 0 {
                                match.appendTiles(newMatch)
                                matches[i] = match
                                hasMatch = true
                                println("match size \(match.tiles.count)")
                            }
                        }
                        if !hasMatch {
                            matches.append(newMatch)
                        }
                        println("Match found!")
                    }
                }
            }
        }
        //Vertical Matching
        for var column = 0; column < GRID_SIZE-2; column++ {
            for var row = 0; row < GRID_SIZE; row++ {
                if let tile1 = tiles[column][row], let tile2 = tiles[column+1][row], let tile3 = tiles[column+2][row] {
                    if tile1.contents == tile2.contents && tile1.contents == tile3.contents {
                        var newMatch = Match(tiles: [tile1, tile2, tile3])
                        matched.unionInPlace(newMatch.tiles)
                        var hasMatch = false
                        for var i = 0; i < matches.count; i++ {
                            var match = matches[i]
                            //check to see if the match is larger than 3 tiles
                            if match.tiles.intersect(newMatch.tiles).count > 0 {
                                match.appendTiles(newMatch)
                                matches[i] = match
                                hasMatch = true
                                println("match size \(match.tiles.count)")
                            }
                        }
                        if !hasMatch {
                            matches.append(newMatch)
                        }
                        println("Match found!")
                    }
                }
            }
        }
        println("Finished check!")
        return !matches.isEmpty
    }
    
    func clearMatch() {
        for match in matches {
            for tile in match.tiles {
                //tile._background.color = CCColor(red: 0, green: 0, blue: 0, alpha: 1)
                //self.dropTileAbove(tile)
                tile.removeFromParent()
                tiles[tile.gridCoordinate.column][tile.gridCoordinate.row] = nil
            }
        }
    }
    
}