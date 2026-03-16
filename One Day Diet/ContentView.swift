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

extension Date {
    var displayLabel: String {
        if Calendar.current.isDateInToday(self) { return "Today" }
        if Calendar.current.isDateInYesterday(self) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: self)
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.scenePhase) private var scenePhase
    @State private var showAboutSheet = false
    @State private var showFaqSheet = false
    @State private var showDatePickerSheet = false
    @State private var showMacros: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.showMacrosKey)
    @State private var activeAlert: ActiveAlert?
    @State private var swipeInsertEdge: Edge = .trailing
    @State private var isAnimating = false
    private var whatsNewAlert = WhatsNewAlert()

    private func changeDate(by days: Int) {
        guard !isAnimating else { return }
        guard let newDate = Calendar.current.date(byAdding: .day, value: days, to: viewModel.currentDate) else { return }
        swipeInsertEdge = days > 0 ? .trailing : .leading
        isAnimating = true
        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.currentDate = newDate
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isAnimating = false
        }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
                    .onChange(of: viewModel.currentDate) { oldValue, newValue in
                        viewModel.updateData(for: newValue)
                    }
                Button("Done") { showDatePickerSheet = false }
                    .padding(.bottom)
            }
            .padding()
            .presentationDetents([.medium])
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
