//
//  BarcodeScannerView.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/31/26.
//

// PURPOSE: Camera-based barcode scanner using AVFoundation to read book ISBNs

import SwiftUI
import AVFoundation

// MARK: - Scanner UIViewRepresentable

/// Wraps AVCaptureSession in a SwiftUI view to scan EAN-13/EAN-8 barcodes (book ISBNs)
struct BarcodeScannerUIView: UIViewControllerRepresentable {
    /// Called when a barcode is successfully scanned
    let onScanned: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onScanned = onScanned
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
}

// MARK: - Scanner View Controller

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onScanned: ((String) -> Void)?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasScanned = false
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            showNoCameraAlert()
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else { return }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let output = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // EAN-13 is the standard barcode format for ISBNs
            output.metadataObjectTypes = [.ean13, .ean8]
        }

        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.addSublayer(preview)
        self.previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }

    private func showNoCameraAlert() {
        let label = UILabel()
        label.text = "Camera not available"
        label.textAlignment = .center
        label.textColor = .white
        label.frame = view.bounds
        view.addSubview(label)
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard !hasScanned,
              let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let isbn = object.stringValue else { return }

        hasScanned = true

        // Haptic feedback on scan
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        onScanned(isbn)
    }
}
