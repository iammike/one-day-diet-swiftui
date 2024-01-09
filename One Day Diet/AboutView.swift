//
//  AboutView.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

struct AboutView: View {
    var dismissAction: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("This app provides tracking for a diet system based roughly on one outlined in [Racing Weight: How to Get Lean for Peak Performance](https://www.goodreads.com/en/book/show/7192581) by Matt Fitzgerald. As translated, this diet is intended to simply get you eating healthier foods. Coupled with adequate exercise, weight loss will likely follow. To begin, eat what you consider to be \"well\" for a day or a few, note those scores, and there's your personal target.")
                    
                    Spacer()
                    
                    Text("Feedback and ideas are more than welcome! I'd love to add features.")
                    
                    Spacer()
                    
                    Link("🌐 My Website", destination: URL(string: "http://www.iammike.org")!)
                        .foregroundColor(.blue)
                    
                    Link("✉️ Email Me", destination: URL(string: "mailto:iammikec@gmail.com")!)
                        .foregroundColor(.blue)
                    
                }
                .padding()
            }
            .navigationBarTitle("About", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                dismissAction()
            })
        }
    }
}

