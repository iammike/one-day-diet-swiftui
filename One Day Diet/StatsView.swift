//
//  StatsView.swift
//  One Day Diet
//
//  Created by Michael Collins on 3/16/26.
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: ViewModel
    var dismissAction: () -> Void

    @State private var selectedRange: StatsRange = .thirtyDays

    private var stats: [DailyStats] { viewModel.dailyStats(for: selectedRange) }
    private var avgScore: Double {
        guard !stats.isEmpty else { return 0 }
        return Double(stats.map(\.score).reduce(0, +)) / Double(stats.count)
    }
    private var highestDay: DailyStats? { stats.max(by: { $0.score < $1.score }) }
    private var avgServings: [Double] { viewModel.averageServings(for: selectedRange) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Picker("Range", selection: $selectedRange) {
                        ForEach(StatsRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    if stats.isEmpty {
                        ContentUnavailableView(
                            "Not enough data yet",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Track a few more days to see your stats here.")
                        )
                        .padding(.top, 40)
                    } else {
                        chartSection
                        summarySection
                        foodGroupsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismissAction() }
                }
            }
        }
    }

    private var chartSection: some View {
        Chart(stats) { day in
            LineMark(
                x: .value("Date", day.date),
                y: .value("Score", day.score)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.green)

            AreaMark(
                x: .value("Date", day.date),
                y: .value("Score", day.score)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                .linearGradient(
                    colors: [.green.opacity(0.25), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(height: 180)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                AxisGridLine()
            }
        }
    }

    private var summarySection: some View {
        HStack(spacing: 10) {
            statCard(
                title: "Avg Score",
                value: String(format: "%.1f", avgScore),
                subtitle: "pts / day"
            )
            statCard(
                title: "Days Tracked",
                value: "\(stats.count)",
                subtitle: selectedRange.days.map { "of \($0)" } ?? "total"
            )
            if let best = highestDay {
                statCard(
                    title: "Highest Day",
                    value: "\(best.score)",
                    subtitle: best.date.displayLabel
                )
            }
        }
    }

    private func statCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.green)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var foodGroupsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Food Groups")
                .font(.headline)
                .padding(.bottom, 8)

            ForEach(0..<foodGroupsData.count, id: \.self) { i in
                let group = foodGroupsData[i]
                let avg = i < avgServings.count ? avgServings[i] : 0
                let isNegative = group.scores[min(1, group.scores.count - 1)] < 0

                HStack(spacing: 12) {
                    Text(group.emoji + " " + group.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    GeometryReader { geo in
                        let maxServings = Double(group.scores.count - 1)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemFill))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(isNegative ? Color.red : Color.green)
                                .frame(width: geo.size.width * min(avg / maxServings, 1.0), height: 6)
                        }
                    }
                    .frame(width: 80, height: 6)

                    Text(String(format: "%.1f", avg))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .trailing)
                }
                .padding(.vertical, 10)

                if i < foodGroupsData.count - 1 {
                    Divider()
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
