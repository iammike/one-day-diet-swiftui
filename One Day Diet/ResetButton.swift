//
//  ResetButton.swift
//  One Day Diet
//
//  Created by Michael Collins on 1/7/24.
//

import SwiftUI

struct ResetButton: View {
    let action: () -> Void
    let label: String

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 20)
    }
}
