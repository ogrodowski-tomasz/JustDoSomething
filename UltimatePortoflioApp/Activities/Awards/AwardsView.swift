//
//  AwardsView.swift
//  UltimatePortfolioApp
//
//  Created by Tomasz Ogrodowski on 08/04/2022.
//

import SwiftUI

struct AwardsView: View {

    static let tag: String? = "Awards"

    @EnvironmentObject var dataController: DataController
    @State private var selectedAward = Award.example
    @State private var showingAlertDetails = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAlertDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundColor(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(Text(award.description))
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(isPresented: $showingAlertDetails, content: getAwardAlert)
    }

    /// Checking if user earned certain award and gives it a color.
    /// - Parameter award: certain award.
    /// - Returns: Color based on Bool value of hasEarned method.
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : Color.secondary.opacity(0.5)
    }

    /// Support for VoiceOver in managing certain Awards.
    /// - Parameter award: current award.
    /// - Returns: Text based on Bool value of hasEarned method.
    func label(for award: Award) -> Text {
        Text(dataController.hasEarned(award: award) ? "Unlocked: \(award.name)" : "Locked")
    }

    /// Managing alerts with cetrain awards
    /// - Returns: Alert with parameters based on Bool value of hasEarned method.
    func getAwardAlert() -> Alert {
        if dataController.hasEarned(award: selectedAward) {
            return Alert(
                title: Text("Unlocked: \(selectedAward.name)"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        } else {
            return Alert(
                title: Text("Locked"),
                message: Text(selectedAward.description),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
