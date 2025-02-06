import SwiftUI

struct FAQScreen: View {
    @State private var expandedSections: [String: Bool] = [:] // Tracks expanded state for each section

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) { // Increased spacing between sections
                Text("Frequently Asked Questions")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)

                // General Questions
                FAQCollapsibleSection(
                    title: "General Questions",
                    icon: "questionmark.circle",
                    isExpanded: bindingForSection("General Questions"),
                    questions: [
                        ("What services do you offer?", "We provide a range of services including collision repair, painting, dent removal, frame straightening, and more."),
                        ("Do I need to make an appointment for an estimate?", "While appointments are preferred, we also accept walk-ins for estimates."),
                        ("How long will the repair process take?", "The duration of repairs depends on the extent of the damage. We will provide an estimated timeline when you bring your vehicle in.")
                    ]
                )

                // Insurance and Payments
                FAQCollapsibleSection(
                    title: "Insurance and Payments",
                    icon: "dollarsign.circle",
                    isExpanded: bindingForSection("Insurance and Payments"),
                    questions: [
                        ("Do you work with insurance companies?", "Yes, we work with most insurance companies to help facilitate the claims process."),
                        ("What if I’m not satisfied with the insurance estimate?", "If you believe the estimate is insufficient, we can discuss your concerns and may assist in negotiating with the insurance company."),
                        ("Do you offer financing options?", "Yes, we offer various financing options to help make the repair costs more manageable.")
                    ]
                )

                // Repairs and Quality
                FAQCollapsibleSection(
                    title: "Repairs and Quality",
                    icon: "wrench.and.screwdriver",
                    isExpanded: bindingForSection("Repairs and Quality"),
                    questions: [
                        ("What types of parts do you use for repairs?", "We use a combination of OEM (Original Equipment Manufacturer) parts and high-quality aftermarket parts, depending on the customer’s preference and budget."),
                        ("Will my car be as good as new after repairs?", "We strive to restore your vehicle to its pre-accident condition, and we guarantee our work with a warranty.")
                    ]
                )

                // Painting Services
                FAQCollapsibleSection(
                    title: "Painting Services",
                    icon: "swatchpalette",
                    isExpanded: bindingForSection("Painting Services"),
                    questions: [
                        ("What types of painting services do you offer?", "We offer full body painting, touch-ups, custom paint jobs, and clear coat applications."),
                        ("How do you ensure a quality paint job?", "We use high-quality paint products and follow a meticulous process to ensure a flawless finish, including surface preparation and multiple layers of paint and clear coat.")
                    ]
                )

                // Vehicle Pick-Up and Drop-Off
                FAQCollapsibleSection(
                    title: "Vehicle Pick-Up and Drop-Off",
                    icon: "car",
                    isExpanded: bindingForSection("Vehicle Pick-Up and Drop-Off"),
                    questions: [
                        ("Can I get a rental car while my vehicle is being repaired?", "Yes, we can help arrange for a rental car during the repair process."),
                        ("Do you offer a pick-up and drop-off service?", "We offer pick-up and drop-off services for customers within a certain radius. Please inquire for details.")
                    ]
                )

                // Warranty and Guarantees
                FAQCollapsibleSection(
                    title: "Warranty and Guarantees",
                    icon: "shield.checkerboard",
                    isExpanded: bindingForSection("Warranty and Guarantees"),
                    questions: [
                        ("Do you provide any warranty on your work?", "Yes, we offer a warranty on our repairs and paint jobs, covering both parts and labor for a specified period."),
                        ("What should I do if I notice an issue after the repair?", "If you notice any issues after picking up your vehicle, please contact us immediately so we can address your concerns.")
                    ]
                )

                // Customer Support
                FAQCollapsibleSection(
                    title: "Customer Support",
                    icon: "phone.fill",
                    isExpanded: bindingForSection("Customer Support"),
                    questions: [
                        ("How can I contact you for more questions?", "You can reach us by phone, email, or through our website's contact form. Our team is happy to assist you with any inquiries.")
                    ]
                )
            }
            .padding()
        }
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper method to get or set the binding for a specific section
    private func bindingForSection(_ section: String) -> Binding<Bool> {
        Binding(
            get: { self.expandedSections[section] ?? false },
            set: { self.expandedSections[section] = $0 }
        )
    }
}

// Reusable FAQ Section with Collapsible Functionality
struct FAQCollapsibleSection: View {
    let title: String
    let icon: String
    @Binding var isExpanded: Bool
    let questions: [(String, String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text(title)
                        .font(.title2)
                        .bold()
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }

            if isExpanded {
                ForEach(questions, id: \.0) { question, answer in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(question)
                            .font(.headline)
                        Text(answer)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }
            }
        }
    }
}
