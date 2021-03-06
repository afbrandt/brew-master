//
//  Gameplay.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/3/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

class Gameplay: CCNode {
    
    //code connected elements
    var _grid: Grid!
    var _gridContainer: CCClippingNode!
    var _gridStencil: CCNode!
    var _bar: Bar!
    var _scoreLabel: CCLabelTTF!
    var spawnNode: CCNode!
    
    var highScoreValue: CCLabelTTF!
    var isGameOver: Bool = false
    static var unsafeScore: Int = 0
    
    //programmatic elements
    var state: GameState!
    private var score: Int = 0 {
        didSet {
            _scoreLabel.string = "\(score)"
        }
    }
    
    func didLoadFromCCB() {
        state = GameState.sharedInstance
        state.currentVenue = "Pub"
        _gridContainer.stencil = _gridStencil
        _gridContainer.alphaThreshold = 0.0
        self.generateGrid()
    }
    
    override func onEnter() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("servedCustomer:"), name: SERVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("gameOver:"), name: GAMEOVER, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("barCleared"), name: EMPTY_BAR, object: nil)
        
        super.onEnter()
        _bar._spawnNode.positionInPoints.x = _bar.convertToNodeSpace(spawnNode.positionInPoints).x
        
    }
    
    override func onExit() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        super.onExit()
    }
    
    func generateGrid() {
//        for var column=0; column<7; column++ {
//            for var row=0; row<7; row++ {
//                var delay = CCTime(column*row/49)
//                
//                var ingredient = state.randomAvailableIngredient()
//                var tile = Tile.tileFromIngredient(ingredient)
//                tile.isNewTile = false
//                _grid.addTileToGrid(tile, atColumn: column, atRow: row)
//                //self.scheduleBlock(^{}, delay: delay)
//            }
//        }
//        _grid.settleTiles()
        _grid.setupNormalGrid()
    }
    
    func servedCustomer(message: NSNotification) {
        score += 1
        Gameplay.unsafeScore += 1
    }
    
    func gameOver(message: NSNotification) {
        CCDirector.sharedDirector().pause()
        let recap = CCBReader.load("Recap", owner: self)
        if score > state.highScore {
            highScoreValue.string = "\(score)"
            state.highScore = score
        } else {
            highScoreValue.string = "\(state.highScore)"
        }
        addChild(recap, z: RECAP_DRAW_ORDER, name: "Recap")
    }
    
    func restart() {
        CCDirector.sharedDirector().resume()
        removeChildByName("Recap")
        let scene = CCBReader.loadAsScene("Gameplay")
//        let transition = CCTransition(fadeWithDuration: 0.5)
        let transition = CCTransition(crossFadeWithDuration: 0.3)
        CCDirector.sharedDirector().replaceScene(scene, withTransition: transition)
    }
    
    func barCleared() {
    
    }
}
