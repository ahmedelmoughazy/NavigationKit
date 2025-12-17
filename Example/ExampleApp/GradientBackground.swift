//
//  BackgroundGradient.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 17.12.25.
//

import SwiftUI

struct GradientBackground: View {

    let gradient: [Color]

    var body: some View {
        LinearGradient(
            colors: gradient.map { $0.opacity(0.3) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
