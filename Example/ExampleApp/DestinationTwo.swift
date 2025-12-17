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
            Button(action: {
                router.present(destination: Details(text: "Detail"), as: .sheet)
            }, label: {
                Text("Present Details")
            })
        }
        .navigationTitle("Destination Two")
    }
    
    @EnvironmentObject private var router: Router
    
}

#Preview {
    DestinationTwo()
}
