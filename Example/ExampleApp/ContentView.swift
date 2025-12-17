//
//  ContentView.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 18.01.24.
//

import SwiftUI
import NavigationKit

struct ContentView: View {
    
    private let router = Router(loggingStyle: .hierarchical)
    
    var body: some View {
        BaseNavigation(router: router) {
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("NavigationKit")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    
                    Text("Navigation Demo")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 20)
                
                GradientButton(
                    title: "Start Navigation",
                    icon: "arrow.right.circle.fill",
                    gradient: [.blue, .cyan]
                ) {
                    router.push(destination: DestinationOne())
                }
                .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GradientBackground(gradient: [.blue, .purple]))
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea(.all)
}
