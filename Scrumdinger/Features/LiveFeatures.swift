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

import AudioRecording
import ScrumStore
import Models

extension Features {
    @MainActor
    static func live() -> Features {
        let scrums = makeScrums()
        let audioRecorder = makeAudioRecorder()
        return Features(
            scrums: scrums,
            audioRecorder: audioRecorder
        )
    }

    @MainActor
    private static func makeScrums() -> Feature.Scrums {
        let store = ScrumStore()
        return .init(
            dependencies: .init(
                load: {
                    try await store.load()
                }, save: { scrums in
                    try await store.save(scrums)
                }
            )
        )
    }

    @MainActor
    private static func makeAudioRecorder() -> Feature.AudioRecorder {
        let recorder = SpeechRecognizer()
        return .init(
            dependencies: .init(
                reset: {
                    recorder.reset()
                }, startTranscription: {
                    try await recorder.startTranscription()
                }, finishTranscription: {
                    recorder.finishTranscription()
                }
            )
        )
    }
}
