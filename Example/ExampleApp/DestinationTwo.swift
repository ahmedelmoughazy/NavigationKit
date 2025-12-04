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
        VStack {
            Button("Show Destination Three") {
                router.push(destination: DestinationThree())
            }
            
            Button("Pop to Root") {
                router.popAll()
            }
        }
        .navigationTitle("Destination Two")
    }
    
    @EnvironmentObject private var router: Router

}

#Preview {
    DestinationTwo()
}
