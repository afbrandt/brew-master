//
//  Grid.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import UIKit

struct GridCoordinate {
    var row: Int = 0
    var column: Int = 0
    
    func isValid() -> Bool {
        if row <= -1 || column <= -1 || row >= 7 || column >= 7 {
            return false
        } else {
            return true
        }
    }
}

enum SlideMode {
    case Horizontal
    case Vertical
    case Unknown
}

enum SlideDirection: Int {
    case Unknown = -1
    case Up = 0
    case Down = 1
    case Left = 2
    case Right = 3
}
enum GridState {
    case Idle
    case Moving
    case Adjusting
    case Matching
    case Animating
}

//MARK: - Main class, lifecycle related methods
class Grid: CCNode {

    var tiles: [[Tile?]] = [[Tile?]](count: 7, repeatedValue: [Tile?](count: 7, repeatedValue: Tile?()))
    var spawnedTiles: [Int] = [Int](count: 7, repeatedValue: 0)
    var spareSlideTiles: [Tile] = []
    var spareDirectedSlideTiles: [[Tile]] = [[Tile]](count: 4, repeatedValue: [Tile]())
    var gameState: GameState!
    var state: GridState = .Idle
    var columnWidth: CGFloat = 0
    var columnHeight: CGFloat = 0
    var tileMarginVertical: CGFloat = 0
    var tileMarginHorizontal: CGFloat = 0
    //Grid+Touch
    var touchTile: Tile!
    var touchCoordinate: CGPoint = ccp(0,0)
    var currentCoordinate: GridCoordinate = GridCoordinate(row: 0, column: 0)
    var tileOffset: CGPoint = ccp(0, 0)
    var lastVector: CGPoint = ccp(0, 0)
    var slideMode: SlideMode = .Unknown {
        willSet {
            if newValue != slideMode {
                for tile in spareSlideTiles {
                    tile.removeFromParent()
                }
                spareSlideTiles.removeAll()
            }
        }
    }
    var slideDirection: SlideDirection = .Unknown {
        willSet {
            if slideDirection != .Unknown && slideDirection != newValue {
                
            }
        }
    }
    //Grid+Match
    var matches: [Match] = [Match]()
    var matched: Set<Tile> = []
    var needsCheck: Bool = false
    var hasPotentialMatch: Bool = false
    
    let GRID_SIZE: Int = 7
    
    func didLoadFromCCB() {
        gameState = GameState.sharedInstance
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
    
    override func update(dt: CCTime) {
//        if spareSlideTiles.count > 0 && (state == .Moving || state == .Adjusting) {
//            checkRowColumn()
//        }
//        
//        if state == .Adjusting && hasPotentialMatch {
//            
//        }
        
        switch state {
        case .Moving:
            if slideDirection != .Unknown && spareDirectedSlideTiles[slideDirection.rawValue].count > 0 {
                checkRowColumn()
            }
        case .Adjusting:
            if hasPotentialMatch {
                let newCoordinate = self.gridCoordinateFromPoint(touchTile.position)
                let newPosition = self.pointFromGridCoordinate(newCoordinate)
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
//                slideRowColumnTile(touchTile, byVector: newPositionVector, forMode:slideMode, animated: true)
                moveRowColumnTile(touchTile, byVector: newPositionVector, inDirection: slideDirection, animated: true)
                
            } else {
//                slideRowColumnTile(touchTile, byVector: CGPointZero, forMode:slideMode, animated: true)
                moveRowColumnTile(touchTile, byVector: CGPointZero, inDirection: slideDirection, animated: true)
            }
            self.state = .Animating
            self.userInteractionEnabled = false
            touchTile = Tile.dummyTile()
        default: break
        }
    }
    
    func setupGrid() {
        let tile = CCBReader.load("Tile")
        columnWidth = tile.contentSize.width
        columnHeight = tile.contentSize.height
        tileMarginHorizontal = (self.contentSize.width - (CGFloat(GRID_SIZE) * columnWidth)) / (CGFloat(GRID_SIZE)+1)
        tileMarginVertical = (self.contentSize.height - (CGFloat(GRID_SIZE) * columnHeight)) / (CGFloat(GRID_SIZE)+1)
    }
    
    func addTileToGrid(tile: Tile, atColumn column: Int, atRow row: Int) {
        let coord = GridCoordinate(row: row, column: column)
        self.addTileToGrid(tile, atGridCoordinate: coord)
    }
    
    func addTileToGrid(tile: Tile, atGridCoordinate coordinate: GridCoordinate) {
        self.addChild(tile)
        let spawnCoordinate = GridCoordinate(row: coordinate.row, column: 8)
        tile.position = self.pointFromGridCoordinate(spawnCoordinate)
        tile.gridCoordinate = coordinate
        if coordinate.isValid() {
            tiles[coordinate.column][coordinate.row] = tile
            self.animateTile(tile, toGridCoordinate: coordinate, notify: false)
        }
    }
    
}