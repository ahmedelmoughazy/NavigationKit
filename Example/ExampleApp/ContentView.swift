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
            VStack {
                Button("Go to destination one") {
                    router.push(destination: DestinationOne())
                }
            }
            .navigationTitle("Root view")
        }
    }
}

#Preview {
    ContentView()
        .ignoresSafeArea(.all)
}
