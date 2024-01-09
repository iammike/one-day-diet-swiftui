//
//  ContentView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/6/24.
//

import SwiftUI

enum ActiveAlert: Identifiable {
    case versionAlert, resetDataAlert

    var id: Self {
        return self
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var selectedDate = Date()
    @State private var showAboutSheet = false
    @State private var showFaqSheet = false
    @State private var activeAlert: ActiveAlert?
    private var whatsNewAlert = WhatsNewAlert()
    
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
                        Button("Clear All Data") { activeAlert = .resetDataAlert }
                        Button("FAQ") { showFaqSheet = true }
                        Button("About") { showAboutSheet = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title)
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
//            Text("Servings: \(viewModel.calculateTotalServings())").font(.body)
            
            List {
                ForEach(0..<foodGroupsData.count, id: \.self) { index in
                    FoodGroupSliderView(foodGroup: foodGroupsData[index], serving: $viewModel.selectedServings[index])
                        .onReceive(viewModel.$selectedServings) { _ in
                            viewModel.sliderValueChanged(on: selectedDate)
                        }
                }
            }
        }
        
        .onAppear {
            if whatsNewAlert.shouldShowAlert() {
                activeAlert = .versionAlert
            }
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .versionAlert:
                return whatsNewAlert.getVersionAlert()
            case .resetDataAlert:
                return Alert(
                    title: Text("Warning"),
                    message: Text("This will reset all application data. Are you sure?"),
                    primaryButton: .destructive(Text("Reset")) {
                        viewModel.clearAllData()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        
        .sheet(isPresented: $showFaqSheet) {
            FaqView() {
                showFaqSheet = false
            }
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
