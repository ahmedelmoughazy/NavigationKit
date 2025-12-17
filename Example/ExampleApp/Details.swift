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
        VStack(spacing: 25) {
            VStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.purple)
                
                Text("Modal Details")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                
                Text("Navigate within a modal presentation")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.bottom, 15)
            
            VStack(spacing: 16) {
                GradientButton(
                    title: "Navigate to Destination One",
                    icon: "arrow.turn.down.right",
                    gradient: [.purple, .indigo]
                ) {
                    router.push(destination: DestinationOne())
                }
                
                GradientButton(
                    title: "Show Alert Example",
                    icon: "bell.badge.fill",
                    gradient: [.pink.opacity(0.4), .purple.opacity(0.6)]
                ) {
                    router.presentAlert(alertItem: .init(
                        title: "Example Alert",
                        message: "This alert won't dismiss the sheet. Try different button styles!",
                        actionButtons: [
                            AlertActionButton(title: "Primary", style: .primary, action: { }),
                            AlertActionButton(title: "Secondary", style: .secondary, action: { }),
                            AlertActionButton(title: "Destructive", style: .destructive, action: { }),
                            AlertActionButton(title: "Cancel", style: .cancel, action: { })
                        ]
                    ))
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GradientBackground(gradient: [.purple, .indigo]))
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    @EnvironmentObject private var router: Router
}

#Preview {
    Details(text: "This is details")
}
