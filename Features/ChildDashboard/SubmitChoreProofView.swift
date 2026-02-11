import SwiftUI

#if canImport(PhotosUI)
import PhotosUI
#endif

struct SubmitChoreProofView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let instance: ChoreInstance

    @State private var selectedKind: ChoreInstance.Proof.Kind = .photo
    @State private var isSubmitting = false

#if canImport(PhotosUI)
    @State private var pickedItem: PhotosPickerItem? = nil
#endif
    @State private var pickedURLString: String? = nil
    @State private var pickedLabel: String? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Submit Proof", subtitle: "Photo/video upload placeholder")

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Proof Type")
                                .font(DS.Typography.cardTitle)

                            Picker("Type", selection: $selectedKind) {
                                Text("Photo").tag(ChoreInstance.Proof.Kind.photo)
                                Text("Video").tag(ChoreInstance.Proof.Kind.video)
                            }
                            .pickerStyle(.segmented)

#if canImport(PhotosUI)
                            PhotosPicker(
                                selection: $pickedItem,
                                matching: selectedKind == .photo ? .images : .videos,
                                photoLibrary: .shared()
                            ) {
                                HStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle")
                                    Text(pickedLabel ?? "Choose from Photos")
                                        .font(DS.Typography.body.weight(.semibold))
                                    Spacer()
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(DS.Colors.softGray.opacity(0.7))
                                )
                            }
                            .onChange(of: pickedItem) { _, newValue in
                                guard let newValue else { return }
                                Task { await loadPickedItem(newValue) }
                            }

                            Text("Saved locally (placeholder). You can upload to cloud later.")
                                .font(DS.Typography.caption)
                                .foregroundStyle(.secondary)
#else
                            Text("This is a placeholder — integrate PhotosUI / camera capture later.")
                                .font(DS.Typography.caption)
                                .foregroundStyle(.secondary)
#endif
                        }
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: isSubmitting ? "Submitting…" : "Submit", systemImage: "arrow.up.circle", isEnabled: !isSubmitting) {
                        submit()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("Proof")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        isSubmitting = true
        withAnimation(.easeInOut(duration: 0.25)) {
            let updated = appState.choreService.submitProof(instance: instance, kind: selectedKind, proofURLString: pickedURLString)
            if let idx = appState.choreInstances.firstIndex(where: { $0.id == instance.id }) {
                appState.choreInstances[idx] = updated
            }
            appState.refreshUnlockStatus()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            dismiss()
        }
    }

#if canImport(PhotosUI)
    private func loadPickedItem(_ item: PhotosPickerItem) async {
        pickedLabel = "Loading…"
        pickedURLString = nil

        switch selectedKind {
        case .photo:
            if let data = try? await item.loadTransferable(type: Data.self) {
                let url = writeToTemp(data: data, fileExtension: "jpg")
                pickedURLString = url?.absoluteString
                pickedLabel = url?.lastPathComponent ?? "Selected"
                return
            }
        case .video:
            if let url = try? await item.loadTransferable(type: URL.self) {
                let copied = copyToTemp(originalURL: url)
                pickedURLString = copied?.absoluteString
                pickedLabel = copied?.lastPathComponent ?? "Selected"
                return
            }
        }

        pickedLabel = "Couldn’t load"
    }

    private func writeToTemp(data: Data, fileExtension: String) -> URL? {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("eys_\(UUID().uuidString).\(fileExtension)")
        do {
            try data.write(to: url, options: [.atomic])
            return url
        } catch {
            return nil
        }
    }

    private func copyToTemp(originalURL: URL) -> URL? {
        let dir = FileManager.default.temporaryDirectory
        let url = dir.appendingPathComponent("eys_\(UUID().uuidString)_\(originalURL.lastPathComponent)")
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            try FileManager.default.copyItem(at: originalURL, to: url)
            return url
        } catch {
            return nil
        }
    }
#endif
}
