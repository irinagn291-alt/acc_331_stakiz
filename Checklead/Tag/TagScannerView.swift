import SwiftUI
import AVFoundation

/// Collar QR capture. Writes TagMark through the vault. Refuses a clipped rail.
struct TagScannerView: View {
    @ObservedObject var vault: JauntVault
    @Environment(\.dismiss) private var dismiss
    @State private var denied = false
    @State private var live = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: ThemeTokens.space * 2) {
                Text("Scan a collar")
                    .font(ThemeTokens.font(.display))
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Text(vault.statusLine)
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                cameraPlate
                Text("Known collars")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                ForEach(vault.ledger.tags) { tag in
                    let name = vault.ledger.pets.first { $0.id == tag.petID }?.name ?? "Pet"
                    Button(name + " " + tag.code) {
                        _ = vault.scan(payload: tag.code)
                        dismiss()
                    }
                    .buttonStyle(PressScaleStyle())
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, ThemeTokens.space)
                    .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: ThemeTokens.chipRadius, style: .continuous))
                }
                Spacer(minLength: ThemeTokens.space)
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(DesignTokens.bg)
            .navigationTitle("Scan collar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
            .onAppear { refreshCamera() }
        }
    }

    @ViewBuilder
    private var cameraPlate: some View {
        if denied {
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                Text("Camera is off. Open Settings to change it.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(SecondaryPressStyle())
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
            .paperCard()
        } else if live {
            CaptureStrip(onCode: { code in
                _ = vault.scan(payload: code)
                dismiss()
            })
            .frame(maxWidth: .infinity, minHeight: 240, maxHeight: 240)
            .clipShape(RoundedRectangle(cornerRadius: ThemeTokens.cardRadius, style: .continuous))
        } else {
            VStack(alignment: .leading, spacing: ThemeTokens.space) {
                Text("Camera waits until you continue.")
                    .font(ThemeTokens.font(.body))
                    .foregroundStyle(DesignTokens.ink)
                Button("Continue") { requestCamera() }
                    .buttonStyle(ProminentPressStyle())
            }
            .padding(ThemeTokens.space * 2)
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
            .paperCard()
        }
    }

    private func refreshCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            denied = true
            live = false
        case .authorized:
            denied = false
            live = true
        default:
            denied = false
            live = false
        }
    }

    private func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { allowed in
            Task { @MainActor in
                denied = !allowed
                live = allowed
            }
        }
    }
}

struct CaptureStrip: UIViewRepresentable {
    var onCode: (String) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCode: onCode) }

    func makeUIView(context: Context) -> Preview {
        let view = Preview()
        view.start(coordinator: context.coordinator)
        return view
    }

    func updateUIView(_ uiView: Preview, context: Context) {
        context.coordinator.onCode = onCode
    }

    final class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var onCode: (String) -> Void
        var fired = false
        init(onCode: @escaping (String) -> Void) { self.onCode = onCode }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard !fired, let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let value = object.stringValue else { return }
            fired = true
            onCode(value)
        }
    }

    final class Preview: UIView {
        private let session = AVCaptureSession()
        private var layerPreview: AVCaptureVideoPreviewLayer?

        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

        func start(coordinator: Coordinator) {
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }
            session.addInput(input)
            let output = AVCaptureMetadataOutput()
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            output.setMetadataObjectsDelegate(coordinator, queue: .main)
            output.metadataObjectTypes = [.qr]
            if let preview = layer as? AVCaptureVideoPreviewLayer {
                preview.session = session
                preview.videoGravity = .resizeAspectFill
                layerPreview = preview
            }
            session.startRunning()
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if window == nil, session.isRunning {
                session.stopRunning()
            }
        }
    }
}
