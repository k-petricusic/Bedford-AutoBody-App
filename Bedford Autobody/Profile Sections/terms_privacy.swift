import SwiftUI

struct TermsPrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Terms of Use")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                
                Text("Last Updated: 02/18/2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                Divider()

                sectionTitle("Agreement to Our Legal Terms")
                sectionText("""
                    We are Bedford Autobody ("Company," "we," "us," "our"). 
                    We operate, as well as any other related products and services that refer or link to these legal terms 
                    (the "Legal Terms") (collectively, the "Services").
                    """)

                sectionText("""
                    These Legal Terms constitute a legally binding agreement made between you, whether personally or on behalf of an entity ("you"),
                    and us, concerning your access to and use of the Services. By accessing the Services, you agree that you have read, 
                    understood, and agreed to be bound by these terms. IF YOU DO NOT AGREE, YOU MUST DISCONTINUE USE IMMEDIATELY.
                    """)

                sectionTitle("1. Our Services")
                sectionText("""
                    The information provided when using the Services is not intended for distribution to or use by any person or entity 
                    in any jurisdiction where such distribution or use would be contrary to law or regulation.
                    """)

                sectionTitle("2. Intellectual Property Rights")
                sectionText("""
                    We are the owner or the licensee of all intellectual property rights in our Services, including all source code, databases, 
                    functionality, software, website designs, audio, video, text, photographs, and graphics.
                    """)

                sectionTitle("3. User Representations")
                sectionText("""
                    By using the Services, you represent and warrant that: 
                    - You have the legal capacity to comply with these terms.
                    - You are not a minor in your jurisdiction.
                    - You will not use the Services for any illegal or unauthorized purpose.
                    - Your use of the Services will comply with all applicable laws.
                    """)

                sectionTitle("4. Prohibited Activities")
                sectionText("""
                    You agree not to:
                    - Use the Services for fraudulent purposes.
                    - Circumvent security measures.
                    - Harass or abuse other users.
                    - Violate any laws in your use of the Services.
                    """)

                sectionTitle("5. User Generated Contributions")
                sectionText("""
                    The Services do not offer users the ability to submit or post content. 
                    However, any contributions made will be subject to ownership and intellectual property terms as outlined.
                    """)

                sectionTitle("6. Termination & Modifications")
                sectionText("""
                    We reserve the right to modify, suspend, or terminate the Services at any time for any reason without prior notice.
                    """)

                sectionTitle("7. Governing Law & Dispute Resolution")
                sectionText("""
                    These terms shall be governed by the laws of California. Any disputes will be resolved through arbitration 
                    or the appropriate legal channels.
                    """)

                sectionTitle("8. Disclaimer & Liability Limitations")
                sectionText("""
                    The Services are provided 'as-is' and 'as-available.' We disclaim all warranties to the fullest extent permitted by law.
                    We shall not be liable for any loss, damage, or interruption in your use of the Services.
                    """)

                sectionTitle("9. Contact Us")
                sectionText("""
                    For any questions regarding these Terms or our Services, please contact us at bedford99@aol.com.
                    """)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Terms & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    // 🔹 Section Title Component
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 10)
    }

    // 🔹 Section Text Component
    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.gray)
            .multilineTextAlignment(.leading)
    }
}
