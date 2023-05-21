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

struct ScrumAddSheet: Provider {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var scrums: Feature.Scrums

    @State private var draft: DailyScrum

    init(draft: DailyScrum = .draft) {
        self._draft = .init(initialValue: draft)
    }

    var entryView: some View {
        EditScrum(
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
    private func handleInterface(_ action: EditScrum.Action) {
        switch action {
        case .noAction:
            break
        }
    }

    // MARK: - State Configurations

    @MainActor
    func applyTargetState(_ state: TargetState) {
        switch state {
        case .reset:
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
            Button(Strings.add.text) {
                scrums.save(draft)
                dismiss()
            }
            .disabled(draft.title.isEmpty)
            .bold()
        }
    }
}

extension ScrumAddSheet {
    enum TargetState {
        case reset
    }
}
