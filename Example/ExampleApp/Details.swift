//
//  DetailView.swift
//  Example
//
//  Created by Ahmed Elmoughazy on 29.02.24.
//

import SwiftUI
import NavigationKit

@Routable
struct Details: View {
    
    let text: String
    
    var body: some View {
        VStack {
            Button("Go to destination one") {
                router.push(destination: DestinationOne())
            }
            
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
                    ))
                },
                label: {
                    Text("Present Alert")
                }
            )
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                
            }
        }
    }
    
    @EnvironmentObject private var router: Router
}

#Preview {
    Details(text: "This is details")
}
