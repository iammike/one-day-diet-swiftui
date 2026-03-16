//
//  ShakeDetector.swift
//  One Day Diet
//
//  Created by Michael Collins on 3/16/26.
//

import SwiftUI

private class ShakeViewController: UIViewController {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }
}

private struct ShakeDetectingView: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeViewController {
        let vc = ShakeViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        background(ShakeDetectingView(onShake: action).frame(width: 0, height: 0))
    }
}
