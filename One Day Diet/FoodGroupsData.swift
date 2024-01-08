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
}

let foodGroupsData: [FoodGroup] = [
    FoodGroup(name: "Fruits", scores: [0, 2, 4, 6, 7, 7, 7], emoji: "🍎"),
    FoodGroup(name: "Vegetables", scores: [0, 2, 4, 6, 7, 7, 7], emoji: "🥦"),
    FoodGroup(name: "Lean Proteins", scores: [0, 2, 4, 5, 5, 5, 4], emoji: "🍗"),
    FoodGroup(name: "Whole Grains", scores: [0, 2, 4, 5, 5, 5, 4], emoji: "🌾"),
    FoodGroup(name: "Nuts & Seeds", scores: [0, 2, 4, 5, 5, 5, 4], emoji: "🥜"),
    FoodGroup(name: "Dairy", scores: [0, 1, 2, 3, 3, 2, 0], emoji: "🥛"),
    FoodGroup(name: "Refined Grains", scores: [0, -1, -2, -4, -6, -8, -10], emoji: "🥐"),
    FoodGroup(name: "Fatty Proteins", scores: [0, -1, -2, -4, -6, -8, -10], emoji: "🍔"),
    FoodGroup(name: "Sweets", scores: [0, -2, -4, -6, -8, -10, -12], emoji: "🍬"),
    FoodGroup(name: "Fried Foods", scores: [0, -2, -4, -6, -8, -10, -12], emoji: "🍟")
]
