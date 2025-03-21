//
//  PDFViewerWrapper.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/3/25.
//


import SwiftUI

struct PDFViewerWrapper: View {
    let url: URL?

    var body: some View {
        if let url = url {
            print("✅ Opening PDFViewer with URL: \(url)")
            return AnyView(PDFViewer(pdfURL: url))
        } else {
            print("❌ No PDF URL found!")
            return AnyView(Text("No PDF Available").foregroundColor(.red))
        }
    }
}
