//
//  FoodGroupsData.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/6/24.
//

struct FoodGroup {
    let name: String
    let scores: [Int]
    let emoji: String
    let maxServingMessage: String
}

let foodGroupsData: [FoodGroup] = [
    FoodGroup(name: "Fruits", scores: [0, 2, 4, 6, 7, 7, 7], emoji: "🍎", maxServingMessage: "Did you get lost in a berry patch?"),
    FoodGroup(name: "Vegetables", scores: [0, 2, 4, 6, 7, 7, 7], emoji: "🥦", maxServingMessage: "You're turning green."),
    FoodGroup(name: "Lean Proteins", scores: [0, 2, 4, 5, 5, 5, 4], emoji: "🍗", maxServingMessage: "Bodybuilder, eh?"),
    FoodGroup(name: "Whole Grains", scores: [0, 2, 4, 5, 5, 5, 4], emoji: "🍿", maxServingMessage: "Keeping regular!"),
    FoodGroup(name: "Nuts & Seeds", scores: [0, 2, 4, 5, 5, 5, 4], emoji: "🐿️", maxServingMessage: "Nice day for foraging, eh?"),
    FoodGroup(name: "Dairy", scores: [0, 1, 2, 3, 3, 2, 0], emoji: "🥛", maxServingMessage: "RIP your stomach."),
    FoodGroup(name: "Refined Grains", scores: [0, -1, -2, -4, -6, -8, -10], emoji: "🥐", maxServingMessage: "Like Oprah, I too love bread."),
    FoodGroup(name: "Fatty Proteins", scores: [0, -1, -2, -4, -6, -8, -10], emoji: "🍔", maxServingMessage: "You can't be feeling good about this."),
    FoodGroup(name: "Sweets", scores: [0, -2, -4, -6, -8, -10, -12], emoji: "🍭", maxServingMessage: "NO MORE TWINKIES!"),
    FoodGroup(name: "Fried Foods", scores: [0, -2, -4, -6, -8, -10, -12], emoji: "🍟", maxServingMessage: "Taking that cheat day to the extreme!")
]
