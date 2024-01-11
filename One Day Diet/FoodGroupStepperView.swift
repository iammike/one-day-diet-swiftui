//
//  FoodGroupStepperView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/11/24.
//

import SwiftUI

struct FoodGroupStepperView: View {
    let foodGroup: FoodGroup
    @Binding var serving: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text(foodGroup.emoji + " " + foodGroup.name)

            Stepper(
                onIncrement: {
                    if serving < foodGroup.scores.count - 1 {
                        serving += 1
                    }
                },
                onDecrement: {
                    if serving > 0 {
                        serving -= 1
                    }
                },
                label: {
                    let currentScore = foodGroup.scores[serving]
                    Text("Servings: \(serving) → Score: \(currentScore)")
                }
            )

            let currentScore = foodGroup.scores[serving]
            let nextIndex = serving + 1
            let scoreChangeByNextServing = nextIndex < foodGroup.scores.count ? foodGroup.scores[nextIndex] - currentScore : 0

            Text("Effect of Next Serving: \(scoreChangeByNextServing > 0 ? "+\(scoreChangeByNextServing)" : "\(scoreChangeByNextServing)")")
                .foregroundColor(scoreChangeByNextServing < 0 ? .red : (scoreChangeByNextServing > 0 ? .green : .primary))
                .opacity(serving == foodGroup.scores.count - 1 ? 0 : 1)
        }
    }
}

