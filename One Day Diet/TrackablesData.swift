//
//  TrackablesData.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/11/24.
//

struct Trackable {
    let name: String
    let unit: String
    let unitsPerServing: Int
    let emoji: String
}

let trackablesData: [Trackable] = [
    Trackable(name: "Water", unit: "oz", unitsPerServing: 4, emoji: "💧"),
    Trackable(name: "Carbs", unit: "g", unitsPerServing: 4, emoji: "⛽"),
    Trackable(name: "Protein", unit: "g", unitsPerServing: 4, emoji: "💪"),
    Trackable(name: "Fat", unit: "g", unitsPerServing: 2, emoji: "🥑")
]
