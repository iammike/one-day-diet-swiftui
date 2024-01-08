//
//  ContentView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        VStack {
            Text("One Day Diet").font(.largeTitle).padding()
            Text("Total Score: \(viewModel.calculateTotalScore())").font(.title)

            ResetButton(action: viewModel.resetServings, label: "Clear Data")

            List {
                ForEach(0..<foodGroupsData.count, id: \.self) { index in
                    FoodGroupSliderView(foodGroup: foodGroupsData[index], serving: $viewModel.selectedServings[index])
                }
            }
        }
    }
}

@main
struct DietApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
