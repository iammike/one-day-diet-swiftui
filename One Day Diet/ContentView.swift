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
    @State private var showAlert = false
    @State private var showAboutSheet = false

    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text("One Day Diet")
                        .font(.largeTitle)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                HStack {
                    Spacer()
                    Menu {
                        Button("Clear Selected Day's Data", action: { viewModel.resetServings(for: selectedDate) })
                        Button("Clear All Data") { showAlert = true }
                        Button("About") { showAboutSheet = true }
                    } label: {
                        Image(systemName: "gear")
                            .font(.body)
                    }
                }.padding(.trailing, 32)
            }
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .onChange(of: selectedDate) {
                    viewModel.updateData(for: selectedDate)
                }
                .labelsHidden()
                .padding(.bottom, 10)
            
            Text("Total Score: \(viewModel.calculateTotalScore())").font(.title)
            
            List {
                ForEach(0..<foodGroupsData.count, id: \.self) { index in
                    FoodGroupSliderView(foodGroup: foodGroupsData[index], serving: $viewModel.selectedServings[index])
                        .onReceive(viewModel.$selectedServings) { _ in
                            viewModel.sliderValueChanged(on: selectedDate)
                        }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Warning"),
                message: Text("This will reset all application data. Are you sure?"),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.clearAllData()
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $showAboutSheet) {
            AboutView() {
                showAboutSheet = false
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
