//
//  TrackableStepper.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/11/24.
//

import SwiftUI

struct TrackableStepperView: View {
    let trackable: Trackable
    @Binding var servings: Int

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(trackable.emoji) \(trackable.name)")

            Stepper(
                onIncrement: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    servings += 1
                },
                onDecrement: {
                    if servings > 0 {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        servings -= 1
                    }
                },
                label: {
                    let totalUnits = servings * trackable.unitsPerServing
                    Text("\(trackable.label)\(totalUnits)")
                }
            )
        }
    }
}
