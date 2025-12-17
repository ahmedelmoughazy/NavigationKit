//
//  DestinationOne.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 29.02.24.
//

import SwiftUI
import NavigationKit

@Routable
struct DestinationOne: View {
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: "1.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.green)
                
                Text("First Stop")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                
                Text("You're at the first destination")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)
            
            GradientButton(
                title: "Continue to Destination Two",
                icon: "arrow.forward",
                gradient: [.green, .mint]
            ) {
                router.push(destination: DestinationTwo())
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground(gradient: [.green, .mint]))
        .navigationTitle("Destination One")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @EnvironmentObject private var router: Router
}
