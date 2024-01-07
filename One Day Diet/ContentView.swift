import SwiftUI

struct ResetButton: View {
    let action: () -> Void
    let label: String

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(label)
                .font(.headline)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle()) // Remove the gray frame
        .padding(.trailing, 20)
    }
}

struct ContentView: View {
    @State private var selectedServings: [Int]

    init() {
        // Load the selectedServings array from UserDefaults
        if let savedServings = UserDefaults.standard.array(forKey: "selectedServings") as? [Int] {
            _selectedServings = State(initialValue: savedServings)
        } else {
            // If no data is found in UserDefaults, initialize with default values
            _selectedServings = State(initialValue: Array(repeating: 0, count: foodGroupsData.count))
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text(getCurrentDate())
                    .font(.title)
                    .padding()
                
                Spacer()
                
                ResetButton(action: {
                    // Reset all values to 0 and save to UserDefaults
                    selectedServings = Array(repeating: 0, count: foodGroupsData.count)
                    UserDefaults.standard.set(selectedServings, forKey: "selectedServings")
                }, label: "Reset All")
            }
            
            Text("Total Score: \(calculateTotalScore())")
                .font(.title)

            List {
                ForEach(0..<foodGroupsData.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(foodGroupsData[index].name)

                        Slider(
                            value: Binding(
                                get: { Double(selectedServings[index]) },
                                set: { selectedServings[index] = Int($0) }
                            ),
                            in: 0...Double(foodGroupsData[index].scores.count - 1),
                            step: 1
                        )

                        let currentScore = foodGroupsData[index].scores[selectedServings[index]]
                        let nextIndex = selectedServings[index] + 1
                        let scoreChangeByNextServing = nextIndex < foodGroupsData[index].scores.count ? foodGroupsData[index].scores[nextIndex] - currentScore : 0
                        
                        Text("Current Score: \(currentScore)")
                            .foregroundColor(.primary)
                        
                        Text("Change by Next Serving: \(scoreChangeByNextServing)")
                            .foregroundColor(scoreChangeByNextServing < 0 ? .red : (scoreChangeByNextServing > 0 ? .green : .primary))
                    }
                }
            }
        }
        .onDisappear {
            // Save the selectedServings array to UserDefaults when the view disappears
            UserDefaults.standard.set(selectedServings, forKey: "selectedServings")
        }
    }
    
    private func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: Date())
    }
    
    private func calculateTotalScore() -> Int {
        var totalScore = 0
        for index in 0..<foodGroupsData.count {
            let currentScore = foodGroupsData[index].scores[selectedServings[index]]
            totalScore += currentScore
        }
        return totalScore
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
