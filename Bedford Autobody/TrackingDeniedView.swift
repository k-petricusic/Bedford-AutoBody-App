//
//  TrackingDeniedView.swift
//  Bedford Autobody
//
//  Created by Bedford Autobody on 3/11/25.
//

import SwiftUI
import AppTrackingTransparency

struct TrackingDeniedView: View {
    let onRetry: () -> Void
    @State private var trackingStatus: ATTrackingManager.AuthorizationStatus = .notDetermined

    var body: some View {
        VStack {
            Text("Tracking Permission Required")
                .font(.title)
                .bold()
                .padding()

            Text("We need your permission to create and manage your account.")
                .multilineTextAlignment(.center)
                .padding()

            Button("Retry") {
                requestTrackingPermission()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Button("Go to Settings") {
                openAppSettings()
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            checkTrackingStatus()
        }
    }

    // ✅ Check the current tracking permission status when the view appears
    func checkTrackingStatus() {
        DispatchQueue.main.async {
            trackingStatus = ATTrackingManager.trackingAuthorizationStatus
            if trackingStatus == .authorized {
                onRetry() // ✅ Automatically trigger onRetry if tracking is granted
            }
        }
    }

    // ✅ Function to re-prompt tracking permission
    func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                trackingStatus = status
                switch status {
                case .authorized:
                    print("✅ Tracking authorized.")
                    onRetry() // ✅ Retry login flow
                case .denied, .restricted:
                    print("❌ Tracking still denied.")
                case .notDetermined:
                    print("❓ Tracking status not determined.")
                @unknown default:
                    print("Unknown tracking status.")
                }
            }
        }
    }

    // ✅ Function to open iOS Settings if permission is still denied
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url) { success in
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        checkTrackingStatus() // ✅ Recheck tracking permission after returning
                    }
                }
            }
        }
    }
}
