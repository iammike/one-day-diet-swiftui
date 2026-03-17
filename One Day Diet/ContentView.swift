//
//  ContentView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showFaqSheet = false
    @State private var showStatsSheet = false
    @State private var showDatePickerSheet = false
    @AppStorage(UserDefaultsKeys.showMacros) private var showMacros = false
    @AppStorage(UserDefaultsKeys.colorSchemePreference) private var colorSchemeRawValue: String = AppColorScheme.system.rawValue
    @State private var showVersionAlert = false
    @State private var showResetAlert = false
    @State private var undoFeedbackTrigger = false
    @State private var swipeInsertEdge: Edge = .trailing
    @State private var isAnimating = false
    private var whatsNewAlert = WhatsNewAlert()

    private func changeDate(by days: Int) {
        guard !isAnimating else { return }
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: viewModel.currentDate) else { return }
        swipeInsertEdge = days > 0 ? .trailing : .leading
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.2)) {
            viewModel.currentDate = newDate
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isAnimating = false
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                if value.translation.width < 0 {
                    guard !Calendar.current.isDateInToday(viewModel.currentDate) else { return }
                    changeDate(by: 1)
                } else {
                    changeDate(by: -1)
                }
            }
    }

    var body: some View {
        VStack {
            ZStack {
                HStack {
                #if !targetEnvironment(macCatalyst)
                    Text("One Day Diet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                #endif
                }

                HStack {
                    Spacer()
                    Menu {
                        Button("😎 What's New?") { showVersionAlert = true }
                        Button("📊 Stats") { showStatsSheet = true }
                        Button("🙋 FAQ / About") { showFaqSheet = true }
                        Divider()
                        Button(showMacros ? "🧪 Hide Macro Tracking " : "🧪 Show Macro Tracking") {
                            showMacros.toggle()
                        }
                        Menu("🌙 Appearance") {
                            ForEach(AppColorScheme.allCases, id: \.rawValue) { scheme in
                                Button {
                                    colorSchemeRawValue = scheme.rawValue
                                } label: {
                                    if colorSchemeRawValue == scheme.rawValue {
                                        Label(scheme.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(scheme.rawValue)
                                    }
                                }
                            }
                        }
                        Divider()
                        Button("🧼 Clear Visible Data", action: { viewModel.resetServings(for: viewModel.currentDate) })
                        Button("💣 Clear All Data") { showResetAlert = true }
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
            .animation(nil, value: viewModel.currentDate)

            // Animated container: slides in/out when date changes
            VStack {
                // Header: swipe gesture lives here only
                VStack {
                    HStack {
                        Button(action: { changeDate(by: -1) }) {
                            Image(systemName: "arrow.left")
                                .opacity(0.9)
                        }.padding()

                        Button(action: { showDatePickerSheet = true }) {
                            Text(viewModel.currentDate.displayLabel)
                                .font(.body)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(.secondarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .foregroundStyle(.primary)

                        Button(action: { changeDate(by: 1) }) {
                            Image(systemName: "arrow.right")
                                .opacity(Calendar.current.isDateInToday(viewModel.currentDate) ? 0 : 0.9)
                        }
                        .disabled(Calendar.current.isDateInToday(viewModel.currentDate))
                        .padding()
                    }
                    .padding(.bottom, 10)

                    Text("Total Score: \(viewModel.calculateTotalScore())")
                        .font(.title)
                }
                .contentShape(Rectangle())
                .simultaneousGesture(swipeGesture)

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
            .id(viewModel.currentDate)
            .transition(.asymmetric(
                insertion: .move(edge: swipeInsertEdge),
                removal: .move(edge: swipeInsertEdge == .trailing ? .leading : .trailing)
            ))
        }
        .sheet(isPresented: $showDatePickerSheet) {
            VStack(spacing: 20) {
                DatePicker("Select Date", selection: $viewModel.currentDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                Button("Done") { showDatePickerSheet = false }
                    .padding(.bottom)
            }
            .padding()
            .presentationDetents([.medium])
        }
        .onChange(of: viewModel.currentDate) { _, newValue in
            viewModel.updateData(for: newValue)
        }
        .onAppear {
            if whatsNewAlert.shouldShowAlert() {
                showVersionAlert = true
            }
            #if targetEnvironment(macCatalyst)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.sizeRestrictions?.minimumSize = CGSize(width: 390, height: 600)
                windowScene.sizeRestrictions?.maximumSize = CGSize(width: 500, height: 950)
            }
            #endif
        }
        .sheet(isPresented: $showVersionAlert) {
            WhatsNewView(title: whatsNewAlert.versionTitle) {
                showVersionAlert = false
            }
        }
        .alert("Warning", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                viewModel.clearAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all application data. Are you sure?")
        }
        .sheet(isPresented: $showFaqSheet) {
            FaqView() {
                showFaqSheet = false
            }
        }
        .sheet(isPresented: $showStatsSheet) {
            StatsView(viewModel: viewModel) {
                showStatsSheet = false
            }
        }
        .onShake {
            viewModel.undoLastChange(for: viewModel.currentDate)
            undoFeedbackTrigger.toggle()
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: viewModel.currentDate)
        .sensoryFeedback(.warning, trigger: undoFeedbackTrigger)
        .onDisappear {
            viewModel.saveData(for: viewModel.currentDate)
        }
        // Updates to today if you last launched the app yesterday
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                viewModel.checkAndUpdateDate()
            }
        }
        .preferredColorScheme(AppColorScheme(rawValue: colorSchemeRawValue)?.colorScheme)
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
