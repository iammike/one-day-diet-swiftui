//
//  ContentView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Text("One Day Diet").font(.largeTitle).padding()
            
            Text("Total Score: \(viewModel.calculateTotalScore())").font(.title)
            
            HStack {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) {
                        viewModel.updateData(for: selectedDate)
                    }
                    .padding()
                Spacer()
                ResetButton(action: viewModel.resetServings, label: "Clear Data").padding()
            }

            List {
                ForEach(0..<foodGroupsData.count, id: \.self) { index in
                    FoodGroupSliderView(foodGroup: foodGroupsData[index], serving: $viewModel.selectedServings[index])
                        .onReceive(viewModel.$selectedServings) { _ in
                            viewModel.sliderValueChanged(on: selectedDate)
                        }
                }
            }
        }
    }
}

@main
struct OneDayDiet: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
