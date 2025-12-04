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
        VStack {            
            Button("Show Destination Two") {
                router.push(destination: DestinationTwo())
            }
        }
        .navigationTitle("Destination One")
    }
    
    @EnvironmentObject private var router: Router
}
