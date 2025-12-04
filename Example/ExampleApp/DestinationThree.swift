//
//  DestinationThree.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 28.07.24.
//

import SwiftUI
import NavigationKit

@Routable
struct DestinationThree: View {
    var body: some View {
        VStack {
            Button("Go to destination one") {
                router.push(destination: DestinationOne())
            }
            
            Button(action: {
                router.present(destination: DetailView(text: "Detail"), as: .sheet)
            }, label: {
                Text("Present Details")
            })
        }
    }
    
    @EnvironmentObject private var router: Router
}
