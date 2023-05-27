//
//  Copyright © 2023 Dennis Müller and all collaborators
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Puddles
import SwiftUI
import IdentifiedCollections
import Models

extension Home {
    struct ScrumEdit: Provider {
        @Environment(\.dismiss) private var dismiss
        @EnvironmentObject private var scrumProvider: ScrumProvider


        @State private var draft: DailyScrum

        init(scrum: DailyScrum) {
            self._draft = .init(initialValue: scrum)
        }

        var entryView: some View {
            EditScrumView(
                interface: .ignore,
                draft: $draft
            )
            .toolbar { toolbarContent }
        }

        func modify(provider: ProviderContent) -> some View {
            NavigationStack {
                provider
            }
        }

        // MARK: - Interface Handlers

        @MainActor
        private func handleInterface(_ action: EditScrumView.Action) {
            switch action {
            case .noAction:
                break
            }
        }

        // MARK: - Utility

        @ToolbarContentBuilder @MainActor
        private var toolbarContent: some ToolbarContent {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(Strings.dismiss.text, role: .cancel) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(Strings.save.text) {
                    scrumProvider.save(draft)
                    dismiss()
                }
                .disabled(draft.title.isEmpty)
                .bold()
            }
        }
    }
}

struct Home_ScrumEdit_Previews: PreviewProvider {
    static let providers = Providers.mock()
    static var previews: some View {
        Home.ScrumEdit(scrum: providers.scrumProvider.scrums.first ?? .mock)
            .environmentObject(HomeRouter())
            .withProviders(providers)
    }
}
