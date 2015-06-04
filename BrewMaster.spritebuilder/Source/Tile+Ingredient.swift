//
//  Tile+Ingredient.swift
//  BrewMaster
//
//  Created by Andrew Brandt on 4/8/15.
//  Copyright (c) 2015 Dory Studios. All rights reserved.
//

import Foundation

struct IngredientProperties {
    
}

enum IngredientType: Int {
    case Leaf
    case Flower
    case Stem
    case Earth
    case Fruit
}

typealias Ingredient = IngredientType

extension Tile {
    
    class func tileFromIngredient(ingredient: Ingredient) -> Tile {
        
        var tile = CCBReader.load("Tile") as! Tile
        //var sprite = CCSprite(imageNamed: "Herb")
        var color: CCColor
        switch(ingredient) {
            case .Leaf:
                color = CCColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                var sprite = CCBReader.load("Entity/Beer") as! CCSprite
                tile.addChild(sprite)
            case .Flower:
                color = CCColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                var sprite = CCBReader.load("Entity/Wine") as! CCSprite
                tile.addChild(sprite)
            case .Stem:
                color = CCColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                var sprite = CCBReader.load("Entity/Whisky") as! CCSprite
                tile.addChild(sprite)
            case .Earth:
                color = CCColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                var sprite = CCBReader.load("Entity/Champagne") as! CCSprite
                tile.addChild(sprite)
            case .Fruit:
                color = CCColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                var sprite = CCBReader.load("Entity/Martini") as! CCSprite
                tile.addChild(sprite)
        }
        tile._background.color = color
        tile.contents = ingredient
        return tile
    }
    
}