import SwiftUI

struct ContactSupportView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                // Contact Information Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contact Us")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                        Text("Phone: (123) 456-7890")
                    }
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                        Text("Email: bedford99@aol.com")
                    }
                }
                .padding(.horizontal)
                
                // Additional spacing between sections
                Spacer().frame(height: 20)
                
                // Visit Us Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Visit Us")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        Text("2145 Old Middlefield Way, Mountain View, CA 94043")
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .background(isDarkMode ? Color.black : Color.white)
            .foregroundColor(isDarkMode ? Color.white : Color.black)
            .navigationTitle("Contact Us")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
