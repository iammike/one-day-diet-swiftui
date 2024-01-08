//
//  FoodGroupSliderView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

struct FoodGroupSliderView: View {
    let foodGroup: FoodGroup
    @Binding var serving: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(foodGroup.emoji + " " + foodGroup.name)

            Slider(
                value: Binding(
                    get: { Double(serving) },
                    set: { serving = Int($0) }
                ),
                in: 0...Double(foodGroup.scores.count - 1),
                step: 1
            )

            let currentScore = foodGroup.scores[serving]
            let nextIndex = serving + 1
            let scoreChangeByNextServing = nextIndex < foodGroup.scores.count ? foodGroup.scores[nextIndex] - currentScore : 0

            Text("Servings: \(serving), Score: \(currentScore)")
                .foregroundColor(.primary)

            Text("Effect of Next Serving: \(scoreChangeByNextServing > 0 ? "+\(scoreChangeByNextServing)" : "\(scoreChangeByNextServing)")")
                .foregroundColor(scoreChangeByNextServing < 0 ? .red : (scoreChangeByNextServing > 0 ? .green : .primary))
                .opacity(serving == Int(foodGroup.scores.count - 1) ? 0 : 1)
        }
    }
}
