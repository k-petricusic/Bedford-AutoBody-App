//
//  pdf_helper.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 1/14/25.
//
import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    var onUpload: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.fileURL = urls.first
            parent.onUpload()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker cancelled.")
        }
    }
}

struct PDFViewer: View {
    let pdfURL: URL

    var body: some View {
        if let pdfDocument = PDFDocument(url: pdfURL) {
            PDFKitView(document: pdfDocument)
        } else {
            Text("Failed to load the PDF.")
                .foregroundColor(.red)
        }
    }
}


struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

