//
//  profile_help.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 2/14/25.
//

import SwiftUI

struct HelpSupportView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Help & Support")
                .font(.headline)

            Divider()

            NavigationLink(destination: ContactSupportView()) {
                HelpRow(icon: "envelope.fill", text: "Contact Support")
            }

            NavigationLink(destination: TermsPrivacyView()) {
                HelpRow(icon: "doc.text.fill", text: "Terms & Privacy")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// 🔹 Reusable Row Component
struct HelpRow: View {
    var icon: String
    var text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(text)
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
