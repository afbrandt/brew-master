//
//  Constants.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 8/22/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

//This one is used in many places, change carefully...
let TILE_CLEAR_TIME = 0.25

//MARK: Drawing Order Constants
let RECAP_DRAW_ORDER = 30
let BAR_DRAW_ORDER = 20
let CUSTOMER_DRAW_ORDER = 10
let TILE_NORMAL_ZORDER = 15
let TILE_TOUCH_ZORDER = 30
let TILE_REMOVE_ZORDER = 100

//MARK: NSNotificationCenter Used Constants
let HIGHSCORE: String = "High Score"
let GAMEOVER: String = "Game Over"
let MATCH: String = "Match Cleared"
let LARGE_MATCH: String = "Large Match Cleared"
let SUPER_MATCH: String = "Super Match Cleared"
let SERVED: String = "Served Customer"
let EMPTY_BAR: String = "Empty Bar"
let MOVED: String = "Moved tiles..."
let FINISHED: String = "Finished clearing tiles!"
let CLEARED: String = "Tiles cleared!"
let SETTLED: String = "Settled tiles..."

