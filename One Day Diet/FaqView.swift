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
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("You've got questions, I've got answers:")
                    
                    Spacer()
                                        
                    Text("**What is a serving?** Think of it as \"one\" of something or an amount that can fit in your hand. One apple, one egg, one slice of bread, two slices of bacon. What's important with this type of tracking is you remaining consistent; you're only comparing with yourself.")
                    
                    Spacer()
                    
                    Text("**What is a lean protein?** 🥩 🥚 🍗")
                    
                    Spacer()
                    
                    Text("**What is a fatty protein?** 🥓 🍔")
                    
                    Spacer()
                    
                    Text("**What is a refined grain?** It is bread-like and the first ingredient is not whole wheat.")
                    
                    Spacer()
                    
                    Text("**What should x, y, or z count as?** Use your best judgement, and again, consistency is all that's important.")
                    
                    Spacer()
                    
                    Text("**X food is made up of three different things, but its quantity is only one serving. How do I log it?** Use your best judgement based on the points you think it should earn or cost. If you can choose a group that aligns fairly well with what is contained in the food, even better.")
                    
                    Spacer()

                    Text("**What if I don't quite eat two servings of something, but definitely more than one?** Round up, round down, use that decision to guide your next similar choice. It'll all come out in the wash.")

                    Spacer()
                    
                    Text("**What's a good number of points per day?** That's for you to figure out. Spend a day or a few eating well and you'll arrive at a rough target. Remember, this is not a weight-loss diet. The amount you eat depends on external factors.")
                    
                    Spacer()
                    
                    HStack {
                        Link("✉️ More questions?", destination: URL(string: "mailto:iammikec@gmail.com")!)
                            .foregroundColor(.blue)
                    }
                    
                }
                .padding()
            }
            .navigationBarTitle("FAQ", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                dismissAction()
            })
        }
    }
}
