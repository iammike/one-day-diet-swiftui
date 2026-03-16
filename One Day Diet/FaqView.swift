//
//  FaqView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/9/24.
//

import SwiftUI

struct FaqView: View {
    var dismissAction: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("How It Works")
                        .font(.headline)

                    Text("This app tracks a diet system based roughly on one outlined in [Racing Weight: How to Get Lean for Peak Performance](https://www.goodreads.com/en/book/show/7192581) by Matt Fitzgerald. The goal is simply to eat healthier foods. Coupled with adequate exercise, weight loss will likely follow. To find your personal target, eat what you consider \"well\" for a day or a few and note those scores.")

                    Text("Additional macro tracking is available (disabled by default, enabled via menu). This is not part of the diet system, but may be useful. These values are not part of your daily score.")

                    Divider()

                    Text("FAQ")
                        .font(.headline)

                    Text("**What is a serving?** Think of it as \"one\" of something or an amount that can fit in your hand. One apple, one egg, one slice of bread, two slices of bacon. What's important with this type of tracking is you remaining consistent; you're only comparing with yourself.")

                    Text("**What is a lean protein?** 🥩 🥚 🍗")

                    Text("**What is a fatty protein?** 🥓 🍔")

                    Text("**What is a refined grain?** It is bread-like and the first ingredient is not whole wheat.")

                    Text("**What should x, y, or z count as?** Use your best judgement, and again, consistency is all that's important.")

                    Text("**X food is made up of three different things, but its quantity is only one serving. How do I log it?** Use your best judgement based on the points you think it should earn or cost. If you can choose a group that aligns fairly well with what is contained in the food, even better.")

                    Text("**What if I don't quite eat two servings of something, but definitely more than one?** Round up, round down, use that decision to guide your next similar choice. It'll all come out in the wash.")

                    Text("**What's a good number of points per day?** That's for you to figure out. Spend a day or a few eating well and you'll arrive at a rough target. Remember, this is not a weight-loss diet. The amount you eat depends on external factors.")

                    Text("**Why doesn't every day appear in my stats?** Days with very few logged servings are considered incomplete and filtered out. The threshold adapts based on your typical usage — once you have a week of data, it uses the median of your daily totals to decide what counts.")

                    Divider()

                    Text("About")
                        .font(.headline)

                    Text("Feedback and ideas are more than welcome! I'd love to add features.")

                    if let websiteURL = URL(string: "http://www.iammike.org") {
                        Link("🌐 My Website", destination: websiteURL)
                            .foregroundColor(.blue)
                    }

                    if let emailURL = URL(string: "mailto:iammikec@gmail.com") {
                        Link("✉️ Email Me", destination: emailURL)
                            .foregroundColor(.blue)
                    }

                    HStack {
                        Spacer()
                        Image("MadeInVermont500px")
                            .resizable()
                            .opacity(0.5)
                            .scaledToFit()
                            .frame(width: 200)
                        Spacer()
                    }
                    .padding(.top, 8)

                }
                .padding()
            }
            .navigationBarTitle("FAQ", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismissAction() }
                }
            }
        }
    }
}
