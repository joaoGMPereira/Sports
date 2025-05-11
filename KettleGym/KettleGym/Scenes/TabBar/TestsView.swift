//
//import Foundation
//
//struct VoiceNote: Identifiable {
//    let id = UUID()
//    let audioURL: URL
//    let field1: String
//    let field2: String
//    let date: Date
//}
//
//import SwiftUI
//import AVFoundation
//
//struct MainRecorderView: View {
//    @State private var field1: String = ""
//    @State private var field2: String = ""
//    @State private var isRecording = false
//    @State private var audioRecorder: AVAudioRecorder?
//    @State private var currentRecordingURL: URL?
//    @State private var recordingTime = 0
//    @State private var timer: Timer?
//    @State private var voiceNotes: [VoiceNote] = []
//    @State private var showToast = false
//    @State private var toastMessage = ""
//    @State private var showValidationErrors = false
//    @State private var isPreparingToRecord = false
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("Informações da Gravação")) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        TextField("Campo 1", text: $field1)
//                            .textInputAutocapitalization(.sentences)
//
//                        if showValidationErrors && field1.trimmingCharacters(in: .whitespaces).isEmpty {
//                            withAnimation {
//                                Text("Campo 1 é obrigatório")
//                                    .foregroundColor(.red)
//                                    .font(.caption)
//                            }
//                        }
//                    }
//
//                    VStack(alignment: .leading, spacing: 4) {
//                        TextField("Campo 2", text: $field2)
//                            .textInputAutocapitalization(.sentences)
//
//                        if showValidationErrors && field2.trimmingCharacters(in: .whitespaces).isEmpty {
//                            withAnimation {
//                                Text("Campo 2 é obrigatório")
//                                    .foregroundColor(.red)
//                                    .font(.caption)
//                            }
//                        }
//                    }
//                }
//
//                Section {
//                    Button {
//                        isRecording ? stopRecording() : startRecording()
//                    } label: {
//                        HStack {
//                            if isPreparingToRecord {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            } else {
//                                Text(isRecording ? "Parar Gravação" : "Gravar")
//                                    .fontWeight(.semibold)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                    }
//                    .disabled(isPreparingToRecord)
//                    .foregroundColor(.white)
//                    .listRowBackground(isRecording ? Color.red : Color.blue)
//
//                    if isRecording {
//                        Text("⏱️ Gravando: \(formatTime(recordingTime))")
//                            .foregroundColor(.gray)
//                    }
//
//                    Button("Salvar Gravação") {
//                        saveVoiceNote()
//                    }
//                    .disabled(currentRecordingURL == nil && isRecording == true)
//                    .listRowBackground(Color.green)
//                    .foregroundColor(.white)
//                }
//
//                if !voiceNotes.isEmpty {
//                    Section("Gravações Salvas") {
//                        NavigationLink("Ver Gravações") {
//                            VoiceNoteListView(voiceNotes: voiceNotes)
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Gravador de Voz")
//            .overlay(
//                Group {
//                    if showToast {
//                        VStack {
//                            Spacer()
//                            Text(toastMessage)
//                                .padding()
//                                .background(Color.black.opacity(0.85))
//                                .foregroundColor(.white)
//                                .cornerRadius(12)
//                                .padding(.bottom, 30)
//                                .transition(.opacity.combined(with: .move(edge: .bottom)))
//                        }
//                        .animation(.easeInOut, value: showToast)
//                    }
//                }
//            )
//        }
//    }
//
//    func startRecording() {
//        isPreparingToRecord = true
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            let filename = UUID().uuidString + ".m4a"
//            let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
//
//            let settings = [
//                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//                AVSampleRateKey: 12000,
//                AVNumberOfChannelsKey: 1,
//                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//            ]
//
//            do {
//                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
//                try AVAudioSession.sharedInstance().setActive(true)
//
//                let recorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//
//                DispatchQueue.main.async {
//                    self.audioRecorder = recorder
//                    self.audioRecorder?.record()
//                    self.currentRecordingURL = audioFilename
//                    self.isRecording = true
//                    self.recordingTime = 0
//                    self.isPreparingToRecord = false
//
//                    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//                        self.recordingTime += 1
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.isPreparingToRecord = false
//                    showToast("Erro ao iniciar gravação")
//                }
//            }
//        }
//    }
//
//
//    func stopRecording() {
//        audioRecorder?.stop()
//        audioRecorder = nil
//        isRecording = false
//        timer?.invalidate()
//    }
//
//    func saveVoiceNote() {
//        withAnimation {
//            showValidationErrors = true
//        }
//
//        guard !field1.trimmingCharacters(in: .whitespaces).isEmpty,
//              !field2.trimmingCharacters(in: .whitespaces).isEmpty else {
//            showToast("Preencha os campos obrigatórios")
//            return
//        }
//
//        guard let url = currentRecordingURL else {
//            showToast("Nenhuma gravação para salvar")
//            return
//        }
//
//        let note = VoiceNote(audioURL: url, field1: field1, field2: field2, date: Date())
//        voiceNotes.insert(note, at: 0)
//        field1 = ""
//        field2 = ""
//        currentRecordingURL = nil
//        showValidationErrors = false
//        showToast("Gravação salva com sucesso!")
//    }
//
//    func showToast(_ message: String) {
//        toastMessage = message
//        showToast = true
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation {
//                showToast = false
//            }
//        }
//    }
//
//    func formatTime(_ seconds: Int) -> String {
//        String(format: "%02d:%02d", seconds / 60, seconds % 60)
//    }
//}
//
//
//import SwiftUI
//
//struct VoiceNoteListView: View {
//    let voiceNotes: [VoiceNote]
//
//    var body: some View {
//        VStack(spacing: 12) {
//            List {
//                ForEach(voiceNotes) { note in
//                    VoiceNoteRowView(note: note)
//                }
//            }
//        }
//        .navigationTitle("Gravações Salvas")
//    }
//}
//
//import SwiftUI
//import AVFoundation
//
//struct VoiceNoteRowView: View {
//    let note: VoiceNote
//    @State private var player: AVAudioPlayer?
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("🕒 \(note.date.formatted(.dateTime))")
//                .font(.caption)
//                .foregroundColor(.gray)
//            Text("📄 Campo 1: \(note.field1)")
//            Text("📄 Campo 2: \(note.field2)")
//
//            Button("▶️ Tocar") {
//                play()
//            }
//            .padding(.top, 4)
//        }
//        .padding(.vertical, 8)
//    }
//
//    func play() {
//        do {
//            player = try AVAudioPlayer(contentsOf: note.audioURL)
//            player?.play()
//        } catch {
//            print("Erro ao tocar áudio: \(error)")
//        }
//    }
//}
//
