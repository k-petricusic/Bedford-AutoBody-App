import SwiftUI

struct AccountSettingsView: View {
    @State private var isNotificationsEnabled = true
    @State private var selectedLanguage = "English"
    
    let languages = ["English", "Spanish", "French"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Account Settings")
                .font(.headline)

            Divider()

            Toggle("Notifications", isOn: $isNotificationsEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .blue))

            Picker("Language", selection: $selectedLanguage) {
                ForEach(languages, id: \.self) { language in
                    Text(language)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
