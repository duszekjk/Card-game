//
//  CompatibleOnChangeModifier.swift
//  tomekgrastycznen25
//
//  Created by Jacek Kałużny on 25/01/2025.
//


import SwiftUI
import Combine

extension View {
    func compatibleOnChange<T: Equatable>(
        of value: T,
        perform action: @escaping (T) -> Void
    ) -> some View {
        modifier(CompatibleOnChangeModifier(value: value, action: action))
    }
}

private struct CompatibleOnChangeModifier<T: Equatable>: ViewModifier {
    let value: T
    let action: (T) -> Void

    @State private var lastValue: T?
    @State private var cancellables = Set<AnyCancellable>()

    func body(content: Content) -> some View {
        content.onAppear {
            if #available(iOS 17.0, *) {
                // No setup needed for iOS 17+; native onChange will handle it.
            } else {
                // For older versions, set up custom change detection.
                setupCustomChangeDetection()
            }
        }
        .onChange(of: value) { newValue in
            if #available(iOS 17.0, *) {
                action(newValue) // Use native onChange for iOS 17+.
            }
        }
    }

    private func setupCustomChangeDetection() {
        Just(value)
            .removeDuplicates()
            .sink { newValue in
                if lastValue != newValue {
                    lastValue = newValue
                    action(newValue)
                }
            }
            .store(in: &cancellables)
    }
}
