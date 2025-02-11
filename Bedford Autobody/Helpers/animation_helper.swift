//
//  animation_helper.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/7/25.
//

import SwiftUI

func animateProgress(selectedCar: Car?, animatedProgress: Binding<Double>, carOffsetY: Binding<CGFloat>, confettiCounter: Binding<Int>) {
    animatedProgress.wrappedValue = 0.0
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        if let repairStates = selectedCar?.repairStates,
           let currentRepairState = selectedCar?.currentRepairState,
           let currentIndex = repairStates.firstIndex(of: currentRepairState) {
            let progress = Double(currentIndex) / Double(repairStates.count - 1)
            withAnimation(.easeOut(duration: 2.0)) {
                animatedProgress.wrappedValue = progress
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                performCarHop(carOffsetY: carOffsetY)
            }

            if currentRepairState == "Ready for pickup" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    confettiCounter.wrappedValue += 1
                }
            }
        }
    }
}

func performCarHop(carOffsetY: Binding<CGFloat>) {
    guard carOffsetY.wrappedValue == 0 else { return } // Prevent multiple hops

    withAnimation(.easeOut(duration: 0.3)) {
        carOffsetY.wrappedValue = -20
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        withAnimation(.easeIn(duration: 0.3)) {
            carOffsetY.wrappedValue = 0
        }
    }
}

// MARK: - Pulse Effect for Empty State
struct PulseEffect: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 1.0 : 0.5)
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

extension View {
    func applyPulseEffect() -> some View {
        self.modifier(PulseEffect())
    }
}
