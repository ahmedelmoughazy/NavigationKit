//
//  DestinationTwo.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 29.02.24.
//

import SwiftUI
import NavigationKit

@Routable
struct DestinationTwo: View {
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "2.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.orange)
                
                Text("Second Stop")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                
                Text("Ready to present a modal?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
            
            GradientButton(
                title: "Present Details Sheet",
                icon: "square.stack.fill",
                gradient: [.orange, .pink]
            ) {
                router.present(destination: Details(text: "Detail"), as: .sheet)
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground(gradient: [.orange, .pink]))
        .navigationTitle("Destination Two")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @EnvironmentObject private var router: Router
    
}

#Preview {
    DestinationTwo()
}
