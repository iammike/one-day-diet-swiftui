//
//  TrackableStepper.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/11/24.
//

import SwiftUI

private let maxTrackableServings = 100

struct TrackableStepperView: View {
    let trackable: Trackable
    @Binding var servings: Int

    var body: some View {
        VStack(alignment: .leading) {
            Stepper(
                onIncrement: {
                    if servings < maxTrackableServings {
                        servings += 1
                    }
                },
                onDecrement: {
                    if servings > 0 {
                        servings -= 1
                    }
                },
                label: {
                    let totalUnits = servings * trackable.unitsPerServing
                    Text("\(trackable.emoji) \(trackable.name): \(totalUnits)\(trackable.unit)")
                }
            )
            .sensoryFeedback(.impact(weight: .medium), trigger: servings)
        }
    }
}
