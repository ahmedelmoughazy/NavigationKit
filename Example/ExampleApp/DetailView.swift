//
//  DetailView.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 29.02.24.
//

import SwiftUI
import NavigationKit

@Routable
struct DetailView: View {
    
    let text: String
    
    var body: some View {
        VStack {
            Button("Go to destination one") {
                router.push(destination: DestinationOne())
            }
            
            Button(action: {
                router.dismiss()
            }, label: {
                Text("Dismiss")
            })
            
            Button(
                action: {
                    router.presentAlert(alertItem: .init(
                            title: "Example Alert",
                            message: "Example Alert Message, explaining different style of the buttons",
                            actionButtons: [
                                AlertActionButton(title: "Secondary Style", style: .secondary, action: { }),
                                AlertActionButton(title: "Primary Style", style: .primary, action: { }),
                                AlertActionButton(title: "Destructive Style", style: .destructive, action: { }),
                                AlertActionButton(title: "Cancel Style", style: .cancel, action: { })
                            ]
                        )
                    )
                },
                label: {
                Text("Show Alert")
            })
        }
        .navigationTitle("Details")
    }
    
    @EnvironmentObject private var router: Router
}

#Preview {
    DetailView(text: "This is details")
}
