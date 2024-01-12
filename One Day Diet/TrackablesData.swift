//
//  TrackablesData.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/11/24.
//

struct Trackable {
    let name: String
    let label: String
    let unitsPerServing: Int
    let emoji: String
}

let trackablesData: [Trackable] = [
    Trackable(name: "Water (8oz servings)", label: "Ounces: ", unitsPerServing: 8, emoji: "💧"),
    Trackable(name: "Protein (5g servings)", label: "Grams: ", unitsPerServing: 5, emoji: "💪")
]
