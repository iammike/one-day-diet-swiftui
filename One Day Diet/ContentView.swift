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

extension UserDefaultsKeys {
    static let showMacrosKey = "showMacros"
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showAboutSheet = false
    @State private var showFaqSheet = false
    @State private var showMacros: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showMacrosKey)
    @State private var activeAlert: ActiveAlert?
    private var whatsNewAlert = WhatsNewAlert()
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                #if !targetEnvironment(macCatalyst)
                    Text("One Day Diet")
                        .font(.largeTitle)
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                        .frame(maxWidth: .infinity, alignment: .center)
                #endif
                }
                
                HStack {
                    Spacer()
                    Menu {
                        Button("😎 What's New?") { activeAlert = .versionAlert }
                        Button("🙋 FAQ") { showFaqSheet = true }
                        Button("ℹ️ About") { showAboutSheet = true }
                        Divider()
                        Button(showMacros ? "🧪 Hide Macro Tracking " : "🧪 Show Macro Tracking") {
                            showMacros.toggle()
                            UserDefaults.standard.set(showMacros, forKey: UserDefaultsKeys.showMacrosKey)
                        }
                        Divider()
                        Button("🧼 Clear Visible Data", action: { viewModel.resetServings(for: viewModel.currentDate) })
                        Button("💣 Clear All Data") { activeAlert = .resetDataAlert }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .opacity(0.9)
                    }
                }
                #if !targetEnvironment(macCatalyst)
                .padding(.trailing, 36)
                #endif
            }
            #if targetEnvironment(macCatalyst)
            .padding()
            #endif
            
            HStack {
                Button(action: {
                    viewModel.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.currentDate) ?? viewModel.currentDate
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }) {
                    Image(systemName: "arrow.left")
                        .opacity(0.9)
                }.padding()
                
                DatePicker("", selection: $viewModel.currentDate, in: ...Date(), displayedComponents: .date)
                    .onChange(of: viewModel.currentDate) { oldValue, newValue in
                        viewModel.updateData(for: newValue)
                    }
                    .labelsHidden()
                
                Button(action: {
                    viewModel.currentDate = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.currentDate) ?? viewModel.currentDate
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }) {
                    Image(systemName: "arrow.right")
                        .opacity(Calendar.current.isDateInToday(viewModel.currentDate) ? 0 : 0.9)
                }
                .disabled(Calendar.current.isDateInToday(viewModel.currentDate))
                .padding()
            }
            .padding(.bottom, 10)
            
            Text("Total Score: \(viewModel.calculateTotalScore())").font(.title)
            
            List {
                ForEach(0..<foodGroupsData.count, id: \.self) { index in
                    FoodGroupStepperView(foodGroup: foodGroupsData[index], serving: $viewModel.selectedServings[index])
                        .onReceive(viewModel.$selectedServings) { _ in
                            viewModel.servingControlValueChanged(on: viewModel.currentDate)
                        }
                }

                if showMacros {
                    Text("MACROS (NOT SCORED)")
                        .foregroundStyle(Color.gray)

                    ForEach(0..<trackablesData.count, id: \.self) { index in
                        TrackableStepperView(trackable: trackablesData[index], servings: $viewModel.selectedTrackableServings[index])
                            .onReceive(viewModel.$selectedTrackableServings) { _ in
                                viewModel.servingControlValueChanged(on: viewModel.currentDate)
                            }
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
        
        .onDisappear {
            viewModel.saveData(for: viewModel.currentDate)
        }

        // Updates to today if you last launched the app yesterday
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                viewModel.checkAndUpdateDate()
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
